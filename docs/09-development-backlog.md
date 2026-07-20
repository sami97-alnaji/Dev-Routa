# Development backlog

## Next implementation increment

Phase 4 GraphQL Studio is the current increment. The foundation is merged, but
the completion branch must close the AST, HTTP, subscription, schema,
persistence, UX, security, testing, CI, and repository-closure gates before it
is marked complete.

1. [x] Implement Drift database and initial schema from the schema draft.
2. [x] Implement secure storage adapter and masking helpers.
3. [x] Implement REST execution through Dio with redacted diagnostics.
4. [x] Persist and edit collections, requests, environments, variables, drafts, settings, and history through the Phase 2 local repository and integrated workflow.
5. [x] Complete response tabs, replay/retention, sanitized copy/export, migration coverage, and Phase 2-safe local inspection tools. WebSocket remains Phase 3 scope.
6. Keep AI provider integration deferred; no payload is sent externally.

## Not in the backlog until later

Cloud synchronization, accounts, collaboration, billing, gRPC, plugin marketplace, mock server, and advanced monitoring.
