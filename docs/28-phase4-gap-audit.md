# Phase 4 GraphQL gap audit

Status: IN PROGRESS

Audit baseline: `main` at merge commit `72f877f2d247cf518d00845e78b94bf461ad02e2`, which merged PR #3. PR #2 and PR #3 are Phase 4 foundations, not Phase 4 closure. The final-closure branch baseline passed `flutter analyze` and 62 tests on Flutter 3.41.8 / Dart 3.11.5.

## Foundation inventory

The merged foundation contains a GraphQL route and adaptive-shell entry, a small editor, typed HTTP execution, cancellation, draft/history tables, schema version 6, AST parsing, initial subscription transport, schema hash/diff tools, and saved-request persistence. The baseline is healthy, but these foundations are not yet a connected GraphQL Studio workflow.

## Requirement audit

| Area | Classification | Evidence and gap |
|---|---|---|
| GraphQL parsing | Complete foundation | `graphql_document_parser.dart` uses `gql` AST parsing with source locations, fragments, directives, variable definitions, duplicate-name validation, and anonymous-operation rules. |
| Domain models | Partial | Operation, request, and response models exist, but response errors are untyped and there are no typed failure categories, schema, subscription, snapshot, diff, metrics, or export models. |
| HTTP execution | Partial / security risk | POST/GET query execution and a basic GET-mutation guard exist. Variables are supplied only by the UI, auth/environment/secure-storage resolution is absent, extensions are omitted, errors are not typed, transport failures are generic, and the service constructs its own Dio without the existing execution/security architecture. |
| Response handling | Partial | Data, errors, extensions, timing, size, and masked response headers are captured. There is no typed location/path/extension model, bounded Unicode-safe preview, raw-body/error/status/timeline UI, or complete partial-success diagnostics. |
| Subscriptions | Partial / disconnected | `graphql-transport-ws` init, ack, subscribe, next, stop, ping/pong, and ack-timeout foundations exist, but reconnect/resubscribe policy, concurrent-tab management, persistence/history, metrics, and a complete UI are absent. |
| Introspection | Partial / disconnected | Introspection parsing, stable schema hashing, basic diff, and denial classification exist, but the explicit connected explorer, cancellation, cache retention, offline browsing, and user-facing states are absent. |
| Schema explorer/diff | Missing | No explorer, operation skeleton generation, snapshot comparison, or conservative change classification exists. |
| Persistence | Partial | `graphql_drafts` and `graphql_history` are minimal tables. Saved-request CRUD, settings, headers/auth semantics, subscriptions, events, schema snapshots, indexes, ownership, retention, replay, and cleanup are absent. Migration coverage currently checks only table availability and sentinel rows. |
| CRUD/drafts | Partial | Saved requests support create/update/move/delete, rename, duplicate, search, reorder, and persistence of extensions, auth secret references, and transport settings. `GraphqlWorkflowCubit` now provides stable independent draft tabs, autosave, restoration, duplicate/close flows, dirty state, saved-request relationship, and isolated active-operation/subscription markers. It is not yet connected to the desktop/mobile GraphQL UI, subscription settings, workspace cascades, or owned-secret cleanup. |
| History | Partial | A sanitized summary can be inserted. Filtering, pin/tags/notes, retention, replay, comparison, safe JSON/JSONL export, and diagnostic bundles are absent. |
| Desktop UX | Placeholder / partial | A single editor and response text panel exist. Variables are basic JSON text, headers/auth/settings/schema/history/tabs are absent, and business logic remains in the widget. |
| Android UX | Missing | No dedicated mobile GraphQL workflow, focused screens, lifecycle handling, accessibility semantics, or GraphQL back protection tests exist. |
| Security/diagnostics | Partial | Existing masking utilities are reused for response headers and summaries. Runtime secret resolution, auth integration, suspicious literals, typed diagnostics, cache safety, connection-parameter masking, and complete GraphQL failure taxonomy are absent. |
| Import/export | Missing | No `.graphql`/`.gql` import, sanitized document export, GraphQL cURL workflow, response-path copy, schema export/diff, or subscription JSONL export exists. |
| Documentation | Documentation gap | Documents 28–37 are not present. The roadmap still needs Phase 4 marked current without claiming completion. |
| Validation/CI | Testing gap | Baseline tests/analyze pass, but Windows and Android Phase 4 builds, deterministic GraphQL HTTP/WebSocket/introspection/schema tests, CI completion, PR verification, merge verification, closure documentation, and the Phase 4 milestone are pending. |

## Security assessment

The current draft repository stores headers as JSON and masks them on write, which risks changing executable input and does not provide secure references. The current HTTP service has no integrated authentication or secret-resolution boundary. These are release-blocking security gaps, not documentation-only gaps.

## Completion gate

Phase 4 must remain IN PROGRESS until AST parsing, HTTP, subscriptions, introspection/schema intelligence, complete persistence/CRUD/history, desktop/mobile workflows, security diagnostics, import/export, builds, CI, merge verification, closure documentation, and the final annotated milestone are all validated.
