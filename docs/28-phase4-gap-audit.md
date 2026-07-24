# Phase 4 GraphQL gap audit

Status: COMPLETE

## Verified baseline

`main` is at `15bb40b5e879d6c1473716c10cfb36354617f4a2`, the merge commit for PR #4 (`feat: complete Phase 4 GraphQL Studio`). Flutter CI succeeded. Final local verification on that commit passed dependency resolution, generation, formatting, analysis, 123 tests, and Windows/Android debug builds. Drift remains schema version 6.

## Requirement audit

| Area | Classification | Remaining gap |
|---|---|---|
| GraphQL parsing | COMPLETE | AST parsing, operation selection, and validation are covered. |
| HTTP execution and history | COMPLETE | Typed execution, cancellation, response diagnostics, searchable filtered history, replay, deletion, and comparison are covered. |
| Saved requests and tabs | COMPLETE | Draft restoration, create/open/save/rename/duplicate/move/reorder/delete, and dirty-tab protection are covered. |
| Subscriptions | COMPLETE | `graphql-transport-ws`, reconnect/resubscribe generation protection, timeline controls, secret isolation, and cleanup are covered. |
| Schema | COMPLETE | Introspection, snapshots, offline restoration, Schema Explorer, comparison, and operation skeleton generation are covered. |
| Windows and Android UX | COMPLETE | Responsive 800x600 and 390x844 coverage is present. |
| Security and migrations | COMPLETE | Secure references, structured/reflected-secret masking, runtime cleanup, TLS and authentication checks, and schema-6 migration coverage are present. |
| Delivery | COMPLETE | PR #4 merged, CI succeeded, and final-main verification completed. |

## Remaining scope

The former gaps above are closed. Advanced import/export formats, richer subscription archives, cloud/team collaboration, additional protocol families, and release distribution/signing are deferred roadmap scope; they are not accepted Phase 4 requirements. See [the repository closure](37-phase4-repository-closure.md) for final evidence. The annotated `v0.4.0-alpha.1` tag has not yet been created.
