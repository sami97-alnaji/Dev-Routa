# Data model

Core entities: Workspace, Collection, Folder, API Request, Request Header, Query Parameter, Request Body, Environment, Environment Variable, Request History, API Response, Response Snapshot, WebSocket Session, and AI Analysis.

Every persisted root entity uses a UUID-compatible `id`, `createdAt`, and `updatedAt`. Secret fields use `secretRef` rather than plaintext storage.
