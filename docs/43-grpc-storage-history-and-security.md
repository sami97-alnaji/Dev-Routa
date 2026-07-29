# gRPC storage, history, and security

Status: IN PROGRESS

Schema 7 adds only additive gRPC data: saved requests, drafts, sanitized
history and stream sessions, descriptor snapshots, and retained events. A
row stores workspace/collection/folder ownership, selection, non-secret JSON
configuration, descriptor source identity, and secure references. It never
stores a token, password, private key, raw authorization metadata, or resolved
certificate material.

Histories are immutable sanitized snapshots. Unary entries retain endpoint,
service, method, status, duration, size, and bounded response metadata. Stream
sessions retain bounded timeline summaries, sequence information, drop count,
terminal status, and sanitized trailers. Search and filters cover invocation
type, status, endpoint, service, and method. Replay always creates a new draft.
Retention is transactional by age, count, and retained-byte budget. Child
events cascade only from their history session; descriptor deletion is
restricted while referenced; workspace deletion is isolated. Replay creates a
new draft without network activity. Unary comparison is JSON-path aware and
stream comparison matches direction plus sequence without fuzzy equivalence.

Secrets are resolved immediately before an operation and cleared on every
terminal path. `SecretMasker` sanitizes nested request/response values, status
text, trailers, reflection results, diagnostics, clipboard/export, and logs.
Descriptor snapshots deliberately exclude runtime metadata.

Repository writes are the mandatory sanitization boundary. They accept runtime
secret values only for immediate redaction and never retain those collections.
Secure reference identifiers and certificate reference identifiers may be
stored, but deleting a saved request does not delete shared secure-store data.
