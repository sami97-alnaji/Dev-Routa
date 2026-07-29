# Phase 5 gRPC Studio execution plan

Status: IN PROGRESS

1. Complete: provision and record a verified `protoc` path and version, activate
   the official Dart plugin, and generate checked-in descriptor and local test
   fixture types through `tool/grpc/generate_test_protos.ps1`.
2. Complete for the descriptor foundation: add pinned official gRPC, Protobuf,
   and direct generated-runtime dependencies, then add
   `lib/features/grpc/{application,data,domain,presentation}` with no widget
   access to channels, Drift, secure storage, deadlines, or descriptor bytes.
3. Complete locally: schema-7 gRPC descriptor, saved-request, draft, invocation
   history, and retained-event tables; additive migrations from versions 1-6;
   repository sanitization, retention, replay, comparison, ownership, revision,
   transaction, foreign-key, and migration sentinel coverage.
4. Complete for the in-memory protocol layer: descriptor import/loading,
   descriptor-driven binary encoding/decoding, explicit stable-v1 reflection,
   unary, server streaming, client streaming, and bidirectional streaming.
   Reflection caching remains part of the schema-7 persistence slice.
5. Compose desktop and mobile gRPC workspaces with independent draft tabs,
   service/method exploration, request/editor/settings, response/timeline,
   history, replay, and comparison.
6. Add deterministic localhost coverage, then run generation, format, analysis,
   tests, Windows and Android debug builds, and `git diff --check`.
7. Only after local verification, obtain separate approval for commit, push, PR,
   merge, closure document, and annotated alpha tag.

The protocol and persistence foundations have passed their focused local gates.
The next implementation slice is the Windows and Android gRPC UI composition;
Phase 5 remains in progress.
