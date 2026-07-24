# Phase 5 test plan

Status: IN PROGRESS

All gRPC integration tests use local loopback generated fixtures. Coverage must
include unary success/server error, deadlines, cancellation, metadata,
environment and secret resolution, reflected-secret masking, TLS validation,
reflection enabled/disabled, proto imports and imported descriptors,
service/method discovery, scalar/nested/repeated/map/enum/oneof encoding,
server/client/bidirectional streaming, client half-close, server completion,
transport failures, statuses/trailers, bounded retention, concurrent-tab
isolation, history/replay/comparison, saved-request lifecycle, schema 1-6
migrations, Windows and Android responsive workflows, and lifecycle cleanup.

Test fixtures must not contact a public service. Every retained fixture value is
non-secret. Generation, formatting, analysis, the complete test suite, Windows
debug build, Android debug build, and `git diff --check` remain release gates.
