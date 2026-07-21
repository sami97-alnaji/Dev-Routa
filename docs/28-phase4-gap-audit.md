# Phase 4 GraphQL gap audit

Status: IN PROGRESS

## Verified baseline

`main` remains `72f877f`. The final-closure branch is synchronized at `52bbb3ed59333f1d3e0b94acc58051694e7700ba`. The preserved implementation commits are `9480968`, `5163345`, `b16b134`, `5b8535b`, `2b195c1`, `f6e7d36`, `927683b`, `503c2a8`, and `dd097d1`.

Verified local evidence: 73 tests passed, `flutter analyze` passed, Windows debug build passed, Android debug build passed, and Drift remains schema version 6. No final PR, merge, closure document, or milestone exists.

## Requirement audit

| Area | Classification | Remaining gap |
|---|---|---|
| GraphQL parsing | COMPLETE | None in the audited scope. |
| HTTP execution/configuration | PARTIAL | Environment resolution, typed result foundations, UTF-8 preview, auth references, and per-tab execution exist. Disabled headers, mutation confirmation, complete response diagnostics, export, and full configuration coverage remain. |
| HTTP history | PARTIAL | Sanitized search, retention, deletion, replay, UI, and JSON-aware comparison foundation exist. Pin/tags/notes, complete filters, exports, diagnostic bundles, immutable failure snapshots, and comparison UI remain. |
| Saved requests/tab safety | PARTIAL | CRUD, drafts, restoration, independent copies, dirty state, and basic close exist. Rename/update confirmation, collection/folder UI, reorder/tree refresh, and mixed close protection remain. |
| Subscriptions | PARTIAL | Tab-owned service/Cubit, connect/disconnect, transport foundation, and bounded timeline exist. Secure connection parameters, reconnect/resubscribe, session history/comparison, advanced timeline/export, and disposal coverage remain. |
| Schema workflows | PARTIAL | Introspection parser, hashing, snapshot persistence/deduplication, basic diff, and operation skeleton generation exist. Connected Explorer UI, offline/retention workflows, full diff classifications, and snapshot UI remain. |
| Desktop UX | PARTIAL | Editor, tabs, configuration foundations, history/replay, and subscription controls exist. Focused response/schema/subscription/history comparison tools, shortcuts, and close dialogs remain. |
| Android UX | MISSING | Dedicated GraphQL mobile workflow, lifecycle/back protection, rotation/process restoration, and accessibility coverage remain. |
| Import/export | MISSING | GraphQL/cURL import, sanitized document/response/history/schema/subscription exports, JSONL, and diagnostic bundles remain. |
| Security/migrations | PARTIAL | References are persisted instead of resolved secrets, masking exists, and TLS disablement is rejected. Full redaction, runtime cleanup, cascade/retention, and security scan coverage remain. |
| Delivery | PARTIAL | Local validation passes. CI, final PR, merge to `main`, closure document, and annotated tag remain. |

## Remaining scope

Implement only the PARTIAL/MISSING items above. Do not reimplement the parser, CRUD foundation, draft tabs, app-shell wiring, centralized execution, HTTP history foundations, subscription foundations, schema hashing/snapshots, or operation skeleton generation.

Phase 4 remains IN PROGRESS until all remaining workflows are connected, persisted where required, secure, tested, built, accepted by CI, merged to `main`, documented, and tagged.
