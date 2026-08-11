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

The schema-7 persistence slice adds 21 focused migration/repository tests. They
cover migration and reopening from every schema version 1-6, sentinel
preservation, indexes, foreign keys, descriptor deduplication and retention,
saved-request ownership and revisions, independent draft restore/autosave,
bounded history pagination, replay, JSON-aware unary comparison, deterministic
stream comparison, finalization, event bounds and cascades, transactional
rollback, workspace isolation, and exact runtime-secret database scans.
## Practical closure gates

Completed historical stress evidence remains valid while its associated files
remain unchanged and is not rerun for every edit. Closure uses bounded gates:
the three deterministic realtime lifecycle regressions run 20 times each, the
realtime session file runs 10 times, and the realtime and gRPC focused groups
run three times each. Realtime assertions use Cubit state and `Completer`
signals rather than fixed-duration waits.

The complete suite runs three times at normal concurrency, once serially, and
five times with recorded numeric random seeds. The captured seed
`1186905880` runs ten times. Generation runs twice and must produce no output
on the second pass; formatting, analysis, platform builds, foreign-key checks,
and raw SQLite secret scans run once. Any genuine failure retains its log and
is diagnosed with at most ten exact reruns. Extended 100/50/20 stability loops
belong to a future non-blocking nightly workflow, not to Phase 5 closure.
