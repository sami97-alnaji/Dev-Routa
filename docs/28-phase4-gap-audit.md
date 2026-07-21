# Phase 4 GraphQL gap audit

Status: IN PROGRESS

Audit baseline: `main` at merge commit `72f877f2d247cf518d00845e78b94bf461ad02e2`, which merged PR #3. PR #2 and PR #3 are Phase 4 foundations, not Phase 4 closure. The final-closure branch baseline passed `flutter analyze` and 62 tests on Flutter 3.41.8 / Dart 3.11.5.

## Current final-closure branch inventory

The branch starts at the synchronized remote commit `b16b134395d455daab6fff681a0224428c73c1bb`, following saved-request CRUD (`9480968`) and the draft/tab workflow (`5163345`). It now has an application-owned HTTP execution boundary (`GraphqlExecutionService`), per-tab execution states and cancellation, a presentation-only GraphQL editor, saved-request search/open/duplicate/delete entry points, and a TLS-safe HTTP settings guard. This remains an in-progress implementation, not a closure claim.

## Requirement audit

| Area | Classification | Evidence and gap |
|---|---|---|
| GraphQL parsing | Complete foundation | `graphql_document_parser.dart` uses `gql` AST parsing with source locations, fragments, directives, variable definitions, duplicate-name validation, and anonymous-operation rules. |
| Domain models | Partial | Operation, request, and response models exist, but response errors are untyped and there are no typed failure categories, schema, subscription, snapshot, diff, metrics, or export models. |
| HTTP execution | Partial | POST/GET query execution, GET-mutation blocking, typed envelope parsing, per-tab cancellation, configured timeouts/redirect policy, secure-reference authentication, and a TLS-safe guard exist. `GraphqlExecutionService -> GraphqlHttpService -> GraphqlRepository` now owns execution/history rather than the widget. Environment substitution, disabled headers, mutation confirmation, explicit HTTP-error classification, bounded previews, and a complete diagnostics surface remain incomplete. |
| Response handling | Partial | Data, errors, extensions, timing, size, and masked response headers are captured. There is no typed location/path/extension model, bounded Unicode-safe preview, raw-body/error/status/timeline UI, or complete partial-success diagnostics. |
| Subscriptions | Partial / disconnected | `graphql-transport-ws` init, ack, subscribe, next, stop, ping/pong, and ack-timeout foundations exist, but reconnect/resubscribe policy, concurrent-tab management, persistence/history, metrics, and a complete UI are absent. |
| Introspection | Partial / disconnected | Introspection parsing, stable schema hashing, basic diff, and denial classification exist, but the explicit connected explorer, cancellation, cache retention, offline browsing, and user-facing states are absent. |
| Schema explorer/diff | Missing | No explorer, operation skeleton generation, snapshot comparison, or conservative change classification exists. |
| Persistence | Partial | `graphql_drafts` and `graphql_history` are minimal tables. Saved-request CRUD, settings, headers/auth semantics, subscriptions, events, schema snapshots, indexes, ownership, retention, replay, and cleanup are absent. Migration coverage currently checks only table availability and sentinel rows. |
| CRUD/drafts | Partial | Saved requests support create/update/move/delete, rename, duplicate, search, reorder, and persistence of extensions, auth secret references, and transport settings. `GraphqlWorkflowCubit` provides stable independent draft tabs, autosave, restoration, duplicate/close flows, dirty state, saved-request relationship, isolated activity markers, and per-tab execution result/failure/timing state. The GraphQL surface now exposes save, search, open-new-tab, duplicate, and delete. Rename confirmation, move/reorder UI, collection/folder tree refresh, and full close/navigation protection remain incomplete. |
| History | Partial | A sanitized summary can be inserted. Filtering, pin/tags/notes, retention, replay, comparison, safe JSON/JSONL export, and diagnostic bundles are absent. |
| Desktop UX | Partial | The responsive screen contains independent tabs, editor, variables, operation selection, save/search/open/duplicate/delete saved requests, and an execution-state response panel. It no longer owns Dio, CancelToken, response parsing, history writes, or execution state. Full configuration, response tabs/search/export, tree moves, comparisons, schema/history/subscription surfaces, keyboard shortcuts, and close dialogs remain missing. |
| Android UX | Missing | No dedicated mobile GraphQL workflow, focused screens, lifecycle handling, accessibility semantics, or GraphQL back protection tests exist. |
| Security/diagnostics | Partial | Existing masking utilities are reused for response headers and summaries. Runtime secret resolution, auth integration, suspicious literals, typed diagnostics, cache safety, connection-parameter masking, and complete GraphQL failure taxonomy are absent. |
| Import/export | Missing | No `.graphql`/`.gql` import, sanitized document export, GraphQL cURL workflow, response-path copy, schema export/diff, or subscription JSONL export exists. |
| Documentation | Documentation gap | Documents 28–37 are not present. The roadmap still needs Phase 4 marked current without claiming completion. |
| Validation/CI | Testing gap | Baseline tests/analyze pass, but Windows and Android Phase 4 builds, deterministic GraphQL HTTP/WebSocket/introspection/schema tests, CI completion, PR verification, merge verification, closure documentation, and the Phase 4 milestone are pending. |

## Security assessment

Saved configurations preserve secret references rather than their resolved values, HTTP response headers and history summaries are sanitized, and insecure certificate verification is rejected before network execution. Environment-secret substitution, redaction coverage for all GraphQL exports/caches/timelines, and runtime-secret cleanup evidence remain release-blocking security work.

## Completion gate

Phase 4 must remain IN PROGRESS until AST parsing, HTTP, subscriptions, introspection/schema intelligence, complete persistence/CRUD/history, desktop/mobile workflows, security diagnostics, import/export, builds, CI, merge verification, closure documentation, and the final annotated milestone are all validated.
