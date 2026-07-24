# Phase 4 GraphQL gap audit

Status: IN PROGRESS

## Verified baseline

`main` remains `72f877f`. The final-closure branch is synchronized at `366d328921eadfc8c915ae0251044dad485797e0`. Preserved implementation commits include `9480968`, `5163345`, `b16b134`, `5b8535b`, `2b195c1`, `f6e7d36`, `927683b`, `503c2a8`, `dd097d1`, `16ad39b`, and `366d328`.

Verified local evidence: 75 tests passed, `flutter analyze` passed, Windows debug build passed, Android debug build passed, and Drift remains schema version 6. Endpoint validation and authentication-header conflict validation are implemented. JSON-aware history comparison remains a domain foundation; comparison UI and export are pending. No final PR, merge, closure document, or milestone exists.

## Requirement audit

| Area | Classification | Remaining gap |
|---|---|---|
| GraphQL parsing | COMPLETE | AST parser and operation selection are covered. |
| HTTP execution | PARTIAL | Central execution, environment resolution, auth references, endpoint/auth validation, typed results, HTTP/non-JSON classification, TLS enforcement, and bounded previews exist. Complete configuration editors, diagnostics and response tools remain. |
| HTTP history | PARTIAL | Sanitized search, retention, deletion, replay, UI, and comparison domain foundation exist. Metadata filters, pin/tags/notes, exports, comparison UI, and diagnostic bundles remain. |
| Saved requests and tabs | PARTIAL | CRUD, drafts, restoration, independent copies, dirty state, and basic UI exist. Rename/move/reorder/refresh and mixed close protection remain. |
| Subscriptions | PARTIAL | Tab-owned service/Cubit, transport foundation, bounded timeline, and connect/disconnect exist. Secure parameters, reconnect/resubscribe, history/comparison/export and advanced lifecycle remain. |
| Schema | PARTIAL | Introspection, hashing, snapshots, deduplication, basic diff, and skeleton generation exist. Connected Explorer, offline/retention UI, and complete diff workflows remain. |
| Desktop UX | PARTIAL | Editor, tabs, configuration foundations, history/replay, and subscription controls exist. Focused response/comparison/schema tools, shortcuts, and close dialogs remain. |
| Android UX | MISSING | Dedicated GraphQL mobile workflow and lifecycle/accessibility coverage remain. |
| Import/export | MISSING | GraphQL/cURL import and sanitized document/response/history/subscription/schema/diagnostic exports remain. |
| Security/migrations | PARTIAL | Secret references, masking, TLS enforcement, and migration basics exist. Full runtime cleanup, redaction scan, cascades, retention, and security coverage remain. |
| Delivery | PARTIAL | Local validation passes. CI, PR, merge, closure document, and milestone remain. |

## Remaining scope

Implement only the PARTIAL/MISSING items above. Do not reimplement completed parser, CRUD foundation, draft tabs, centralized execution, history foundations, subscription foundations, schema persistence, or skeleton generation.

Phase 4 remains IN PROGRESS until all remaining workflows are connected, persisted, secure, tested, built, accepted by CI, merged to `main`, documented, and tagged.
