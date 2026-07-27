[CmdletBinding()]
param(
  [string]$ProtocPath,
  [string]$ProtobufIncludePath,
  [string]$DartPluginPath
)

$ErrorActionPreference = 'Stop'

$toolRoot = Join-Path $env:LOCALAPPDATA 'DevRoute\toolchains\protobuf\35.0'
$protoc = if ($ProtocPath) { $ProtocPath } else { Join-Path $toolRoot 'bin\protoc.exe' }
$includePath = if ($ProtobufIncludePath) {
  $ProtobufIncludePath
} else {
  Join-Path $toolRoot 'include'
}
$pubCache = if ($env:PUB_CACHE) { $env:PUB_CACHE } else { Join-Path $env:LOCALAPPDATA 'Pub\Cache' }
$plugin = if ($DartPluginPath) {
  $DartPluginPath
} else {
  Join-Path $pubCache 'bin\protoc-gen-dart.bat'
}
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$runtimeOutput = Join-Path $projectRoot 'lib\features\grpc\data\generated'
$reflectionRoot = Join-Path $projectRoot 'tool\grpc\protos'
$reflectionOutput = Join-Path $runtimeOutput 'reflection'
$fixtureRoot = Join-Path $projectRoot 'test\fixtures\grpc'
$fixtureOutput = Join-Path $fixtureRoot 'generated'

if (-not (Test-Path -LiteralPath $protoc)) { throw "Missing verified protoc: $protoc" }
if (-not (Test-Path -LiteralPath $includePath)) { throw "Missing protoc include root: $includePath" }
if (-not (Test-Path -LiteralPath $plugin)) { throw "Missing protoc_plugin executable: $plugin" }
if ((& $protoc --version) -ne 'libprotoc 35.0') { throw 'Expected libprotoc 35.0.' }
$activePackages = & dart pub global list
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect globally activated Dart packages.' }
if ($activePackages -notcontains 'protoc_plugin 25.0.0') {
  throw 'Expected globally activated protoc_plugin 25.0.0.'
}

New-Item -ItemType Directory -Force -Path $runtimeOutput, $reflectionOutput, $fixtureOutput | Out-Null

$descriptorArguments = @(
  "--plugin=protoc-gen-dart=$plugin",
  "--proto_path=$includePath",
  "--dart_out=$runtimeOutput",
  (Join-Path $includePath 'google\protobuf\descriptor.proto')
)
& $protoc @descriptorArguments
if ($LASTEXITCODE -ne 0) { throw 'Descriptor generation failed.' }

$reflectionArguments = @(
  "--plugin=protoc-gen-dart=$plugin",
  "--proto_path=$reflectionRoot",
  "--dart_out=grpc:$reflectionOutput",
  (Join-Path $reflectionRoot 'grpc\reflection\v1\reflection.proto')
)
& $protoc @reflectionArguments
if ($LASTEXITCODE -ne 0) { throw 'Reflection generation failed.' }

$fixtureArguments = @(
  "--plugin=protoc-gen-dart=$plugin",
  "--proto_path=$fixtureRoot",
  "--proto_path=$includePath",
  "--dart_out=grpc:$fixtureOutput",
  (Join-Path $fixtureRoot 'phase5_test_service.proto')
)
& $protoc @fixtureArguments
if ($LASTEXITCODE -ne 0) { throw 'Fixture generation failed.' }

$fixtureDescriptorArguments = @(
  "--proto_path=$fixtureRoot",
  "--proto_path=$includePath",
  '--include_imports',
  "--descriptor_set_out=$(Join-Path $fixtureOutput 'phase5_test_service.protoset')",
  (Join-Path $fixtureRoot 'phase5_test_service.proto')
)
& $protoc @fixtureDescriptorArguments
if ($LASTEXITCODE -ne 0) { throw 'Fixture descriptor generation failed.' }

$descriptorFile = Join-Path $runtimeOutput 'google\protobuf\descriptor.pb.dart'
$source = [System.IO.File]::ReadAllText($descriptorFile)
$ignore = '// ignore_for_file: unintended_html_in_doc_comment'
if (-not $source.Contains($ignore)) {
  $needle = '// ignore_for_file: non_constant_identifier_names, prefer_relative_imports'
  if (-not $source.Contains($needle)) { throw 'Unexpected generated descriptor header.' }
  $source = $source.Replace($needle, "$needle`n$ignore")
  [System.IO.File]::WriteAllText($descriptorFile, $source, [System.Text.UTF8Encoding]::new($false))
}
