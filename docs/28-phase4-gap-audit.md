# Phase 4 GraphQL gap audit

Status: IN PROGRESS

Audit baseline: `main` at merge commit `1b5cb583579ff6f665c77dc46e1aac29b2fb6f07`, created from PR #2. PR #2 is a Phase 4 foundation merge, not Phase 4 closure.

## Foundation inventory

The merged foundation contains a GraphQL route and adaptive-shell entry, a small editor, basic HTTP execution, cancellation, draft/history tables, schema version 6, initial models, and lexical parser tests. The baseline is healthy: 51 tests pass, `flutter analyze` passes, generated Drift code is current, and Dart formatting is clean.

## Requirement audit

| Area | Classification | Evidence and gap |
|---|---|---|
| GraphQL parsing | Incorrect implementation | `graphql_document_parser.dart` uses regular expressions and brace balancing. It has no maintained AST dependency, source locations, fragments, directives, variable definitions, duplicate-name validation, or anonymous-operation rules. |
| Domain models | Partial | Operation, request, and response models exist, but response errors are untyped and there are no typed failure categories, schema, subscription, snapshot, diff, metrics, or export models. |
| HTTP execution | Partial / security risk | POST/GET query execution and a basic GET-mutation guard exist. Variables are supplied only by the UI, auth/environment/secure-storage resolution is absent, extensions are omitted, errors are not typed, transport failures are generic, and the service constructs its own Dio without the existing execution/security architecture. |
| Response handling | Partial | Data, errors, extensions, timing, size, and masked response headers are captured. There is no typed location/path/extension model, bounded Unicode-safe preview, raw-body/error/status/timeline UI, or complete partial-success diagnostics. |
| Subscriptions | Missing | No `graphql-transport-ws` protocol, connection lifecycle, ack timeout, ping/pong, reconnect/resubscribe policy, event metrics, or subscription UI exists. |
| Introspection | Missing | No explicit introspection action, schema parser, snapshot cache, retention, hash, or denial classification exists. |
| Schema explorer/diff | Missing | No explorer, operation skeleton generation, snapshot comparison, or conservative change classification exists. |
| Persistence | Partial | `graphql_drafts` and `graphql_history` are minimal tables. Saved-request CRUD, settings, headers/auth semantics, subscriptions, events, schema snapshots, indexes, ownership, retention, replay, and cleanup are absent. Migration coverage currently checks only table availability and sentinel rows. |
| CRUD/drafts | Partial | A repository can save/list basic drafts, but it is not connected to collections/folders/workspaces, has no independent tab restoration/autosave/dirty protection, and does not preserve the full execution configuration. |
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
