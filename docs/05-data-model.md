# Data model

Core entities: Workspace, Collection, Folder, API Request, Request Header, Query Parameter, Request Body, Environment, Environment Variable, Request History, API Response, Response Snapshot, WebSocket Session, and AI Analysis.

Every persisted root entity uses a UUID-compatible `id`, `createdAt`, and `updatedAt`. Secret fields use `secretRef` rather than plaintext storage.

Schema version 5 preserves the Phase 1/2 resources and adds realtime configurations, realtime drafts, sanitized realtime history with protocol/workspace/collection/request/environment/status/failure metadata, pin/tags/notes, persisted realtime retention controls, and non-secret AI consent/provider metadata. Secret values remain exclusively in secure storage and SQLite stores references only.
## Phase 4 data

GraphQL drafts, saved requests, history summaries, and schema snapshots are local metadata. Secret values remain outside SQLite and must be resolved only at execution time.
