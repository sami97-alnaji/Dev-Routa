# Phase 5 gRPC Studio execution plan

Status: IN PROGRESS

1. Complete: provision and record a verified `protoc` path and version, activate
   the official Dart plugin, and generate checked-in descriptor and local test
   fixture types through `tool/grpc/generate_test_protos.ps1`.
2. Complete for the descriptor foundation: add pinned official gRPC, Protobuf,
   and direct generated-runtime dependencies, then add
   `lib/features/grpc/{application,data,domain,presentation}` with no widget
   access to channels, Drift, secure storage, deadlines, or descriptor bytes.
3. Add schema-7 tables and additive migrations, repository methods, secure
   reference cleanup, retention, and migration sentinel tests.
4. Implement descriptor import, reflection by explicit action, offline cache,
   dynamic validation/codec, unary and all streaming invocation modes.
5. Compose desktop and mobile gRPC workspaces with independent draft tabs,
   service/method exploration, request/editor/settings, response/timeline,
   history, replay, and comparison.
6. Add deterministic localhost coverage, then run generation, format, analysis,
   tests, Windows and Android debug builds, and `git diff --check`.
7. Only after local verification, obtain separate approval for commit, push, PR,
   merge, closure document, and annotated alpha tag.

The descriptor foundation has passed its local gates. The next task may begin at
the unary transport slice; this document does not authorize it.
