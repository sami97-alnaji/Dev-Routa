# gRPC storage, history, and security

Status: IN PROGRESS

Schema 7 will add only additive gRPC data: saved requests, drafts, sanitized
history and stream sessions, descriptor snapshots, and workspace settings. A
row stores workspace/collection/folder ownership, selection, non-secret JSON
configuration, descriptor source identity, and secure references. It never
stores a token, password, private key, raw authorization metadata, or resolved
certificate material.

Histories are immutable sanitized snapshots. Unary entries retain endpoint,
service, method, status, duration, size, and bounded response metadata. Stream
sessions retain bounded timeline summaries, sequence information, drop count,
terminal status, and sanitized trailers. Search and filters cover invocation
type, status, endpoint, service, and method. Replay always creates a new draft.
Retention, deletion, safe JSON export, unary comparison, and stream-session
comparison reuse the existing workspace policy patterns.

Secrets are resolved immediately before an operation and cleared on every
terminal path. `SecretMasker` sanitizes nested request/response values, status
text, trailers, reflection results, diagnostics, clipboard/export, and logs.
Descriptor snapshots deliberately exclude runtime metadata.
