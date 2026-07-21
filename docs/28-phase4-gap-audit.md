# Phase 4 GraphQL gap audit

Status: IN PROGRESS

## Verified baseline

`main` is at `72f877f2d247cf518d00845e78b94bf461ad02e2` (PR #3 foundation merge). The current final-closure branch is `feat/graphql-phase4-final-closure`, synchronized with origin at `5b8535b1ab9a9f3a6b691cbb8ea85a0c2a0a51e5` (`5b8535b feat: centralize GraphQL tab execution`).

The branch preserves saved-request CRUD (`9480968`), draft/tab workflow (`5163345`), app-shell wiring (`b16b134`), and centralized HTTP tab execution (`5b8535b`). At this commit, local `flutter analyze`, 66 tests, Windows debug build, and Android debug build pass. This is not Phase 4 closure evidence: there is no final PR, final CI run, merge to `main`, repository-closure document, or milestone tag.

## Current requirement audit

| Area | Classification | Verified current state and remaining gap |
|---|---|---|
| GraphQL parsing | COMPLETE | `graphql_document_parser.dart` uses the `gql` AST with source locations, fragments, directives, variable definitions, duplicate-name validation, and anonymous-operation rules. |
| Domain and typed errors | PARTIAL | Requests, operations, responses, typed `GraphqlFailure` categories, and typed GraphQL errors exist. Errors preserve message, locations, paths, and extensions. A complete result-classification, history, subscription-session, metrics, comparison, and export model set remains missing. |
| HTTP execution | PARTIAL | `GraphqlScreen -> GraphqlWorkflowCubit -> GraphqlExecutionService -> GraphqlHttpService -> GraphqlRepository` owns execution. The UI owns neither Dio, CancelToken, response-envelope parsing, history writes, nor execution state. POST/GET queries, GET-mutation blocking, auth secure references, timeouts, redirect policy, per-tab cancellation, and TLS rejection are present. Environment substitution, disabled headers, header secret references, mutation confirmation, explicit HTTP classifications, bounded preview, and full diagnostics remain incomplete. |
| Response handling | PARTIAL | Data, typed errors, extensions, status, timing, byte size, and masked response headers are captured. Bounded Unicode-safe preview, truncation state, response views, search, safe copy/export, and complete partial-success diagnostics are missing. |
| Saved requests and drafts | PARTIAL | Repository CRUD persists extensions, auth secure references, settings, ordering, and location. Workflow tabs autosave, restore, duplicate, track dirty state, and isolate execution. UI includes save, search, open in a new tab, duplicate, and delete foundations. Rename/update confirmation, move/reorder UI, tree refresh, and complete close/navigation protection are incomplete. |
| HTTP history and comparison | PARTIAL / MISSING | A sanitized minimal summary is recorded. Immutable records, filters, retention, pin/tags/notes, replay, export, comparison, and their integration/security tests are missing. |
| Subscriptions | PARTIAL / DISCONNECTED | `graphql-transport-ws` handshake, ack, subscribe, next, stop, ping/pong, and ack-timeout foundations exist. Per-tab application state, reconnect/resubscribe, bounded timeline, persistence, comparison, and connected UI are missing. |
| Introspection and schema | PARTIAL / DISCONNECTED | Introspection parsing, stable hashing, basic snapshots/diff, and denial classification exist. Connected explorer UI, cancellation, cache retention/offline browsing, conservative comparison, and operation skeleton generation are missing. |
| Desktop UX | PARTIAL | The responsive editor supports independent tabs, operations, variables, saved requests, execution, cancellation, and response-state display. It lacks complete configuration, focused response/history/schema/subscription tools, shortcuts, and close dialogs. |
| Android UX | MISSING | There is no dedicated GraphQL workflow with GraphQL-specific navigation, lifecycle, accessibility, and compact-layout coverage. |
| Import/export | MISSING | GraphQL document/cURL import, sanitized request/response/schema/history exports, JSONL, diagnostic bundles, and round-trip/redaction tests are absent. |
| Security and diagnostics | PARTIAL | Saved configuration persists secret references rather than resolved values; headers/history are sanitized; TLS verification cannot be disabled. Environment resolution, runtime-secret cleanup proof, reflected-secret redaction coverage, suspicious-literal diagnostics, connection-parameter masking, cache/export safety, and diagnostics UI remain incomplete. |
| Drift schema 6 | PARTIAL | Schema version remains 6 and prior migrations are covered. GraphQL-specific cascade, indexing, history/subscription retention, and secret-reference cleanup coverage remain incomplete. |
| Documentation | PARTIAL | Documents `28` through `36` exist. `docs/37-phase4-repository-closure.md` must not be created until implementation is complete and merged/verified on `main`. |
| Validation and delivery | PARTIAL | Local analysis, 66 tests, Windows debug build, and Android debug build pass at `5b8535b`. Remaining GraphQL coverage, final CI, PR, merge, final-main verification, closure documentation, and tag are pending. |

## Remaining implementation backlog

Only the following Partial, Disconnected, and Missing work is in scope for continuation. Completed parser, saved-request foundation, draft tabs, app-shell wiring, centralized execution, and current local validation are excluded.

1. HTTP configuration, environment resolution, result classification, bounded previews, diagnostics, response UI, and deterministic local-server tests.
2. Complete saved-request UI, tab close/navigation safety, and GraphQL-specific Android lifecycle coverage.
3. Sanitized HTTP history, retention/filtering/replay/export, and HTTP comparison.
4. Subscription application architecture, full `graphql-transport-ws` lifecycle, timeline, session history, comparison, UI, and tests.
5. Connected schema explorer, snapshots/retention/offline use, conservative schema comparison, and operation skeleton generation.
6. Complete desktop and Android GraphQL surfaces, import/export, and diagnostics UI.
7. Security/migration/cascade coverage followed by documentation, CI, PR, merge, main verification, closure document, and annotated milestone.

## Completion gate

Phase 4 remains IN PROGRESS until every remaining workflow above is connected, persisted where applicable, secure, tested, validated on Windows and Android, accepted by CI, merged to `main`, documented by `docs/37-phase4-repository-closure.md`, and tagged as `v0.4.0-alpha.1`.
