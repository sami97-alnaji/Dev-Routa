import 'dart:async';
import 'dart:convert';
import '../../security/secret_masker.dart';
import 'agent_process_policy.dart';

class AgentProcessRequest {
  const AgentProcessRequest({this.operationId = '', required this.executablePath, required this.arguments, required this.workingDirectory, this.requestedEnvironment = const {}, this.allowedEnvironmentKeys = const {}, required this.timeout, required this.maximumStdoutBytes, required this.maximumStderrBytes});
  final String operationId, executablePath, workingDirectory; final List<String> arguments; final Map<String,String> requestedEnvironment; final Set<String> allowedEnvironmentKeys; final Duration timeout; final int maximumStdoutBytes, maximumStderrBytes;
}
enum AgentProcessStatus { completed, cancelled, timedOut, policyRejected, failed }
class AgentProcessResult { const AgentProcessResult({required this.status, this.exitCode, required this.stdout, required this.stderr, required this.originalStdoutBytes, required this.retainedStdoutBytes, required this.originalStderrBytes, required this.retainedStderrBytes, required this.stdoutTruncated, required this.stderrTruncated, this.failureCategory}); final AgentProcessStatus status; final int? exitCode; final String stdout, stderr; final int originalStdoutBytes, retainedStdoutBytes, originalStderrBytes, retainedStderrBytes; final bool stdoutTruncated, stderrTruncated; final String? failureCategory; }
abstract interface class AgentProcessRunner { Future<AgentProcessResult> run(AgentProcessRequest request); Future<void> cancel(String operationId); }
class FakeAgentProcessRunner implements AgentProcessRunner {
  FakeAgentProcessRunner({AgentProcessPolicyValidator? validator, this.stdout = 'ok', this.stderr = '', this.exitCode = 0, this.gate, this.failure}) : validator = validator ?? const AgentProcessPolicyValidator(AgentProcessPolicy(allowedExecutablePaths: <String>{}, allowedWorkspaceRoots: <String>{}, allowedEnvironmentKeys: <String>{}));
  final AgentProcessPolicyValidator validator; final String stdout,stderr; final int exitCode; final Completer<void>? gate; final Object? failure; AgentProcessRequest? lastRequest; final runs=<String,_OwnedProcessRun>{};
  @override Future<AgentProcessResult> run(AgentProcessRequest request) {
    final decision=validator.validate(request); if(!decision.allowed) return Future.value(_result(AgentProcessStatus.policyRejected,request,category:decision.rejection!.name));
    if(runs.containsKey(request.operationId)) return Future.value(_result(AgentProcessStatus.failed,request,category:'duplicate_operation'));
    lastRequest=request; final owned=_OwnedProcessRun(request); runs[request.operationId]=owned; unawaited(_execute(owned)); return owned.terminal.future;
  }
  Future<void> _execute(_OwnedProcessRun owned) async { final timer=Timer(owned.request.timeout,()=>owned.complete(_result(AgentProcessStatus.timedOut,owned.request,category:'timeout'))); try { if(gate!=null) await gate!.future; if(failure!=null) { owned.complete(_result(AgentProcessStatus.failed,owned.request,category:'execution_failure')); } else { owned.complete(_result(AgentProcessStatus.completed,owned.request,code:exitCode)); } } catch(_) { owned.complete(_result(AgentProcessStatus.failed,owned.request,category:'execution_failure')); } finally { timer.cancel(); owned.executionSettled.complete(); runs.remove(owned.request.operationId); } }
  AgentProcessResult _result(AgentProcessStatus status,AgentProcessRequest r,{int? code,String? category}) { final o=_truncate(stdout,r.maximumStdoutBytes), e=_truncate(stderr,r.maximumStderrBytes); return AgentProcessResult(status:status,exitCode:code,stdout:o.$1,stderr:e.$1,originalStdoutBytes:o.$2,retainedStdoutBytes:o.$3,originalStderrBytes:e.$2,retainedStderrBytes:e.$3,stdoutTruncated:o.$4,stderrTruncated:e.$4,failureCategory:category); }
  static (String,int,int,bool) _truncate(String text,int limit) { final original=utf8.encode(text).length; final bytes=utf8.encode(SecretMasker.redactText(text)); final kept=<int>[]; for(final b in bytes.take(limit<0?0:limit)){kept.add(b);} while(kept.isNotEmpty){try{return (utf8.decode(kept),original,kept.length,kept.length<bytes.length);}catch(_){kept.removeLast();}} return ('',original,0,bytes.isNotEmpty); }
  @override Future<void> cancel(String operationId) async { final owned=runs[operationId]; if(owned==null) return; owned.complete(_result(AgentProcessStatus.cancelled,owned.request,category:'cancelled')); }
}
class _OwnedProcessRun { _OwnedProcessRun(this.request); final AgentProcessRequest request; final terminal=Completer<AgentProcessResult>(); final executionSettled=Completer<void>(); void complete(AgentProcessResult value){if(!terminal.isCompleted) terminal.complete(value);} }
