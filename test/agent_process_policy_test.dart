// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:convert';
import 'package:devroute_ai_studio/core/agent_control/data/agent_process_policy.dart';
import 'package:devroute_ai_studio/core/agent_control/data/agent_process_runner.dart';
import 'package:flutter_test/flutter_test.dart';

final policy = AgentProcessPolicyValidator(const AgentProcessPolicy(
  allowedExecutablePaths: {'C:\\Program Files\\DevRoute Test Agent\\agent.exe'},
  allowedWorkspaceRoots: {'C:\\workspace'},
  allowedEnvironmentKeys: {'DEVROUTE_RUN_ID', 'LANG'}, maximumTimeout: Duration(seconds: 1), maximumArgumentBytes: 50,
  absoluteMaximumStdoutBytes: 8, absoluteMaximumStderrBytes: 8));
AgentProcessRequest request({String id='r', String exe='C:\\Program Files\\DevRoute Test Agent\\agent.exe', String dir='C:\\workspace', List<String> args=const [], Map<String,String> env=const {}, Duration timeout=const Duration(milliseconds: 50), int out=8, int err=8}) => AgentProcessRequest(operationId:id,executablePath:exe,arguments:args,workingDirectory:dir,requestedEnvironment:env,timeout:timeout,maximumStdoutBytes:out,maximumStderrBytes:err);
void main(){
 test('policy table rejects unsafe request categories',(){
  final cases=<AgentProcessRequest,AgentProcessPolicyRejection>{request(id:''):AgentProcessPolicyRejection.invalidOperationId,request(exe:'agent.exe'):AgentProcessPolicyRejection.executableNotAbsolute,request(exe:'C:\\cmd.exe'):AgentProcessPolicyRejection.shellLauncherRejected,request(args:['/c']):AgentProcessPolicyRejection.shellModeArgumentRejected,request(dir:'C:\\workspace2'):AgentProcessPolicyRejection.workingDirectoryEscape,request(env:{'TOKEN':'x'}):AgentProcessPolicyRejection.sensitiveEnvironmentKey,request(out:9):AgentProcessPolicyRejection.outputLimitExceedsPolicy};
  for(final e in cases.entries) expect(policy.validate(e.key).rejection,e.value);
 });
 test('normalization and ordinary arguments are accepted',(){expect(policy.validate(request(exe:'c:/program files/devroute test agent/./agent.exe',dir:'C:/workspace/a/../b',args:['; rm -rf /','&& echo injected'])).allowed,isTrue);});
 test('fake runner bounds utf8 output and redacts secrets',() async {final result=await FakeAgentProcessRunner(validator:policy,stdout:'عربي OPENAI_API_KEY=secret',stderr:'😀😀').run(request(out:5,err:5));expect(result.status,AgentProcessStatus.completed);expect(result.retainedStdoutBytes,lessThanOrEqualTo(5));expect(result.retainedStderrBytes,lessThanOrEqualTo(5));expect(result.stdout, isNot(contains('secret')));});
 test('cancellation and duplicate active ids are terminal',() async {final gate=Completer<void>();final runner=FakeAgentProcessRunner(validator:policy,gate:gate);final active=runner.run(request(id:'same'));expect((await runner.run(request(id:'same'))).failureCategory,'duplicate_operation');await runner.cancel('same');gate.complete();expect((await active).status,AgentProcessStatus.cancelled);});
 test('request limits have typed rejections',(){
  final cases=<AgentProcessRequest,AgentProcessPolicyRejection>{request(timeout:Duration.zero):AgentProcessPolicyRejection.invalidTimeout,request(timeout:const Duration(seconds:2)):AgentProcessPolicyRejection.timeoutExceedsPolicy,request(out:-1):AgentProcessPolicyRejection.invalidOutputLimit,request(args:List<String>.filled(33,'x')):AgentProcessPolicyRejection.tooManyArguments,request(args:['é' * 3000]):AgentProcessPolicyRejection.argumentTooLarge,request(env:{'LANG':'x','DEVROUTE_RUN_ID':'x','A':'x','B':'x','C':'x','D':'x','E':'x','F':'x','G':'x'}):AgentProcessPolicyRejection.tooManyEnvironmentEntries};for(final e in cases.entries)expect(policy.validate(e.key).rejection,e.value);
 });
 test('allowlist and working directory containment are boundary aware',(){
  expect(policy.validate(request(exe:'C:\\other\\agent.exe')).rejection,AgentProcessPolicyRejection.executableNotAllowed);
  expect(policy.validate(request(dir:'C:\\workspace\\child')).allowed,isTrue);
  expect(policy.validate(request(dir:'C:\\workspace\\..\\outside')).rejection,AgentProcessPolicyRejection.workingDirectoryEscape);
  expect(policy.validate(request(dir:'C:\\unrelated')).rejection,AgentProcessPolicyRejection.workingDirectoryEscape);
 });
 test('environment is default deny and does not expose values',(){
  expect(policy.validate(request(env:{'LANG':'hu'})).allowed,isTrue);
  final unknown=policy.validate(request(env:{'OTHER':'secret-value'}));
  expect(unknown.rejection,AgentProcessPolicyRejection.environmentKeyNotAllowed);expect(unknown.rejection!.name,isNot(contains('secret-value')));
  expect(policy.validate(request(env:{'Authorization':'x'})).rejection,AgentProcessPolicyRejection.sensitiveEnvironmentKey);
 });
 test('shell modes reject while data arguments are preserved',() async {for(final a in ['/k','-c','-Command','-EncodedCommand','--command'])expect(policy.validate(request(args:[a])).rejection,AgentProcessPolicyRejection.shellModeArgumentRejected);final args=['; rm -rf /','| powershell','`whoami`','\$env:SECRET'];final runner=FakeAgentProcessRunner(validator:policy);await runner.run(request(args:args));expect(runner.lastRequest!.arguments,args);});
 test('output metadata handles zero, exact and unicode boundaries',() async {final zero=await FakeAgentProcessRunner(validator:policy,stdout:'abc',stderr:'😀').run(request(out:0,err:0));expect([zero.originalStdoutBytes,zero.retainedStdoutBytes,zero.stdoutTruncated],[3,0,true]);final exact=await FakeAgentProcessRunner(validator:policy,stdout:'abcd').run(request(out:4));expect(exact.stdoutTruncated,isFalse);final unicode=await FakeAgentProcessRunner(validator:policy,stdout:'عرب').run(request(out:2));expect(utf8.encode(unicode.stdout).length,lessThanOrEqualTo(2));});
 test('timeout is terminal and id becomes reusable after settlement',() async {final gate=Completer<void>();final runner=FakeAgentProcessRunner(validator:policy,gate:gate);final timed=await runner.run(request(id:'timeout',timeout:const Duration(milliseconds:1))).timeout(const Duration(seconds:2));expect(timed.status,AgentProcessStatus.timedOut);expect((await runner.run(request(id:'timeout'))).failureCategory,'duplicate_operation');gate.complete();await Future<void>.microtask((){});expect((await runner.run(request(id:'timeout'))).status,AgentProcessStatus.completed);});
}
