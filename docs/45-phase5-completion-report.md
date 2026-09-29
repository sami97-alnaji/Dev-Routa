Status: IN PROGRESS

# Phase 5 gRPC Studio completion report

## Baseline evidence

The Phase 5 worktree was created at
`C:\\Users\\samis\\StudioProjects\\devRouta_phase5_grpc` on `feat/grpc-phase5`
from `origin/main` at `649df956ed322a770804f3d2bef2fd6b7b059f13`. The peeled
`v0.4.0-alpha.1` tag resolves to the same commit. Flutter 3.41.8, Dart 3.11.5,
schema version 6, `flutter analyze`, 123 tests, Windows debug build, Android
debug build, and `git diff --check` passed at baseline.

## Descriptor foundation batch

The local compiler is `libprotoc 35.0`; the official Dart generator is
`protoc_plugin 25.0.0`. `grpc 5.1.0`, `protobuf 6.0.0`, and direct
`fixnum 1.1.1` resolve successfully. The deterministic generator produces the
runtime Google descriptor types under `lib/features/grpc/data/generated/` and
test-only service stubs under `test/fixtures/grpc/generated/`.

The batch adds bounded descriptor loading/indexing, safe proto import policy,
descriptor-backed JSON validation, and focused regression coverage. Its gates
pass in the current combined verification: `flutter analyze`, 141 tests,
Windows debug build, Android debug build, and `git diff --check`. No reflection,
schema 7, persistence, or UI is claimed implemented.

## Unary transport batch

The native unary transport invokes descriptor-selected method paths with raw
Protobuf bytes and supports metadata, deadlines, cancellation, response headers,
trailers, and structured gRPC failures. Metadata and failure text are sanitized
before they leave the transport boundary.

Deterministic loopback coverage verifies successful descriptor-selected
invocation, status mapping, deadline expiry, cancellation, request metadata,
response metadata redaction, reflected runtime-secret masking, concurrent-call
isolation, endpoint validation, explicit plaintext opt-in, lifecycle cleanup,
and rejection of streaming descriptors. The descriptor and unary focused suite
passes 18 tests. The complete suite passes 141 tests, `flutter analyze` reports
no issues, both debug platform builds succeed, repeated Protobuf generation is
identical, and `git diff --check` reports no whitespace errors. Reflection,
streaming, the dynamic binary codec, schema 7, persistence, and UI remain in
progress.

## Dynamic codec, explicit reflection, and streaming batch

The descriptor-driven codec encodes and decodes scalar, enum, nested, repeated
packed, map, oneof, optional, proto2-required, and supported well-known values.
It applies deterministic field/map ordering, canonical base64 and 64-bit decimal
string policies, unknown-field skipping, malformed-wire failures, and bounded
bytes, recursion, repeated items, and decoded fields.

Explicit server discovery uses generated official stable
`grpc.reflection.v1` types. It lists services, resolves symbol descriptors and
dependencies recursively, deduplicates canonical files, rejects conflicts,
enforces operation limits, maps disabled/auth/deadline/cancellation outcomes,
sanitizes diagnostics, and releases runtime secrets.

The shared raw transport implements server, client, and bidirectional streaming
with descriptor-selected paths, ordered events, headers/trailers/status,
deadline, cancellation, client half-close, session-generation invalidation,
bounded outbound queues and retained timelines, concurrent isolation, and
terminal cleanup. The application layer validates/encodes every sent message and
decodes/sanitizes every received message while retaining bounded raw bytes.

The gRPC-focused suite passes 45 tests and the complete suite passes 168 tests.
Generation is identical across two consecutive runs, `flutter analyze` reports
no issues, Windows and Android debug builds succeed, and `git diff --check`
reports no whitespace errors. At that checkpoint, schema 7 and persistence had
not started; the following batch supersedes that local status. UI has not
started.

## Schema 7 and persistence batch

Schema version 7 adds descriptor snapshots, gRPC Saved Requests, independent
drafts, unified unary/streaming invocation history, and retained stream events.
The migration is additive from every supported version 1-6, preserves legacy
sentinels, creates deterministic indexes, enables foreign keys, passes
`foreign_key_check`, and reopens successfully without inventing gRPC rows.

The repository validates workspace/collection/folder and descriptor ownership,
deduplicates descriptors by workspace fingerprint, protects referenced
snapshots, applies optimistic revisions, uses transactions for compound writes,
and sanitizes every structured/text write by sensitive key and exact runtime
secret. History supports bounded filtering/pagination, one-time streaming
finalization, ordered bounded events, retention, cascade cleanup, replay into a
new draft, JSON-path unary comparison, and direction/sequence streaming
comparison. Shared secure references are retained; resolved secret values and
runtime session objects are never persisted.

The persistence-focused suite passes 21 tests and the complete suite passes 185
tests. Consecutive build-runner execution produces no output or generated
drift, formatting is clean, `flutter analyze` reports no issues, Windows and
Android debug builds succeed, both artifacts exist, and `git diff --check`
reports no whitespace errors. No Windows or Android gRPC UI was started.

The previous high-count stability runs remain historical evidence and are not a
per-edit closure requirement. Practical closure is bounded: the deterministic
realtime cancel-during-reconnect, stale-old-connection, and reconnect lifecycle
regressions each pass 20/20; the realtime session file passes 10/10; and the
realtime and gRPC focused groups pass 3/3. These regressions use `Completer`
signals and Cubit state, with no fixed-duration assertion synchronization.

The captured full-suite seed `1186905880` passes 10/10. The complete suite
passes 3/3 normally, once for each of the numeric seeds `104729`, `224737`,
`32452843`, `49979687`, and `67867967`, and 1/1 with `--concurrency=1`.
Build runner produces 28 outputs on its first regeneration and none on its
second; formatting, analysis, the full suite, Windows and Android debug builds,
`foreign_key_check`, raw SQLite secret scanning, and `git diff --check` pass.
No Windows or Android gRPC UI was started.

Future extended 100/50/20 stability stress belongs to a non-blocking nightly
workflow and does not block this Phase 5 foundation.

This report must remain `IN PROGRESS` until UI integration, CI, merged-main
verification, repository closure documentation, and the next annotated
milestone have all succeeded.

## Phase 5A subscription agent control foundation

This current foundation adds only typed command, tool, permission, approval,
audit, automation-validation, and fake subscription-agent contracts. It has no
UI, real provider adapter, login, credential access, external process, network
execution, schema migration, or gRPC UI work. Future client integrations must
use `SubscriptionAgentAdapter` and `AgentOrchestrator`; the legacy
`ExternalAiProvider` remains an analysis-only boundary with consent previews.
