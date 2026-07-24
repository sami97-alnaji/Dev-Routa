[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$toolRoot = Join-Path $env:LOCALAPPDATA 'DevRoute\toolchains\protobuf\35.0'
$protoc = Join-Path $toolRoot 'bin\protoc.exe'
$includePath = Join-Path $toolRoot 'include'
$pubCache = if ($env:PUB_CACHE) { $env:PUB_CACHE } else { Join-Path $env:LOCALAPPDATA 'Pub\Cache' }
$plugin = Join-Path $pubCache 'bin\protoc-gen-dart.bat'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$runtimeOutput = Join-Path $projectRoot 'lib\features\grpc\data\generated'
$fixtureRoot = Join-Path $projectRoot 'test\fixtures\grpc'
$fixtureOutput = Join-Path $fixtureRoot 'generated'

if (-not (Test-Path -LiteralPath $protoc)) { throw "Missing verified protoc: $protoc" }
if (-not (Test-Path -LiteralPath $includePath)) { throw "Missing protoc include root: $includePath" }
if (-not (Test-Path -LiteralPath $plugin)) { throw "Missing protoc_plugin executable: $plugin" }
if ((& $protoc --version) -ne 'libprotoc 35.0') { throw 'Expected libprotoc 35.0.' }

New-Item -ItemType Directory -Force -Path $runtimeOutput, $fixtureOutput | Out-Null

$descriptorArguments = @(
  "--plugin=protoc-gen-dart=$plugin",
  "--proto_path=$includePath",
  "--dart_out=$runtimeOutput",
  (Join-Path $includePath 'google\protobuf\descriptor.proto')
)
& $protoc @descriptorArguments
if ($LASTEXITCODE -ne 0) { throw 'Descriptor generation failed.' }

$fixtureArguments = @(
  "--plugin=protoc-gen-dart=$plugin",
  "--proto_path=$fixtureRoot",
  "--dart_out=grpc:$fixtureOutput",
  (Join-Path $fixtureRoot 'phase5_test_service.proto')
)
& $protoc @fixtureArguments
if ($LASTEXITCODE -ne 0) { throw 'Fixture generation failed.' }

$descriptorFile = Join-Path $runtimeOutput 'google\protobuf\descriptor.pb.dart'
$source = [System.IO.File]::ReadAllText($descriptorFile)
$ignore = '// ignore_for_file: unintended_html_in_doc_comment'
if (-not $source.Contains($ignore)) {
  $needle = '// ignore_for_file: non_constant_identifier_names, prefer_relative_imports'
  if (-not $source.Contains($needle)) { throw 'Unexpected generated descriptor header.' }
  $source = $source.Replace($needle, "$needle`n$ignore")
  [System.IO.File]::WriteAllText($descriptorFile, $source, [System.Text.UTF8Encoding]::new($false))
}
