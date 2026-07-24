# Phase 5 gRPC Studio gap audit

Status: IN PROGRESS

## Verified starting point

`feat/grpc-phase5` is a clean worktree from `origin/main` at
`649df956ed322a770804f3d2bef2fd6b7b059f13`. The peeled
`v0.4.0-alpha.1` tag resolves to that same commit. Flutter 3.41.8, Dart
3.11.5, schema version 6, analysis, 123 tests, and Windows and Android debug
builds passed before Phase 5 work.

## Reusable architecture

The workspace, collection and folder ownership model; environment resolution;
secure-storage references; `SecretMasker`; Drift migration harness; bounded
realtime timelines; GraphQL draft/history/comparison patterns; responsive shell;
and CI build gates are reusable. Phase 5 must integrate with them rather than
introduce a second database or secret store.

## Missing gRPC capabilities

No current dependency or module loads `FileDescriptorSet`, implements the
reflection protocol, dynamically encodes a descriptor-defined message, or owns
a native gRPC channel. There are no persisted gRPC drafts, requests, history,
stream sessions, descriptor snapshots, UI routes, or tests.

## Package and platform decision

The maintained official `grpc` package 5.1.0 is the candidate native client. It
supports Flutter on Windows and Android and exposes channels, client methods,
calls, TLS credentials, metadata, deadlines, cancellation, unary calls, and
streaming calls. `protobuf` 6.0.0 is the official runtime. Neither package is a
runtime `.proto` parser or a ready reflection client.

`protoc_plugin` 25.0.0 is the official Dart generator, but it requires a
separately installed `protoc` 3.0.0 or newer. `protoc` and `protoc-gen-dart` are
not on this machine's PATH. The older third-party `protobuf_wellknown` package
was evaluated only as a descriptor source and is not accepted as an
unmaintained production dependency.

## Risks and required controls

| Risk | Control |
| --- | --- |
| Arbitrary `.proto` parsing | Use verified `protoc`; never write a handwritten parser. |
| Reflection disabled | Show an explicit state and retain an offline descriptor snapshot; manual import remains available after compiler provisioning. |
| Dynamic field encoding | Build only from generated official descriptor/reflection types and descriptor metadata; reject unknown fields and expose field paths. |
| HTTP/2/TLS | TLS is the default; plaintext requires an explicit visible setting. Never accept invalid certificates globally. |
| Windows and Android | Test native `grpc` on both debug build targets; no browser/gRPC-Web requirement. |
| Secret exposure | Persist references only, resolve immediately before channel use, mask every retained/displayed/exported value, and clear runtime values on all terminal paths. |
| Streaming retention | Bound events, bytes, and history records per workspace settings. |

## Migration assessment

Phase 5 needs persisted drafts, saved workflows, sanitized histories/sessions,
descriptor snapshots, and non-secret connection settings. That requires schema
version 7 with additive migrations from versions 1 through 6. Existing REST,
realtime, and GraphQL rows must remain intact; there is no reset migration.

## Test-server strategy and exclusions

Tests will use generated local loopback gRPC fixtures only, including reflection
enabled and disabled variants and TLS fixtures. Public servers are excluded.
SOAP, MQTT, Socket.IO, webhooks, a proxy, runners, cloud features, accounts,
teams, billing, browser support, hosted infrastructure, server implementation,
and Phase 6 are out of scope. gRPC-Web remains deferred.

## Descriptor foundation status

The verified local `protoc 35.0` toolchain and `protoc_plugin 25.0.0` are now
available through an explicit deterministic generator. The initial foundation
loads bounded `FileDescriptorSet` inputs, indexes services/messages/enums,
checks dependencies and duplicate symbols, enforces safe imports, and validates
descriptor-shaped JSON without executing imported source. `fixnum 1.1.1` is a
direct dependency because the official generated descriptor type imports it.

This closes only the compiler/descriptor-foundation blocker. Transport,
reflection, persistence/schema 7, and UI are intentionally not implemented in
this change.
