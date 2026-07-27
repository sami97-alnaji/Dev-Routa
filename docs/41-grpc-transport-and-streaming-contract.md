# gRPC transport and streaming contract

Status: IN PROGRESS

Each invocation has an opaque runtime ID, one descriptor-selected method, one
resolved connection configuration, a bounded event buffer, and one terminal
state. Supported modes are unary, server streaming, client streaming, and
bidirectional streaming.

`start`, `send`, `complete client stream`, `cancel`, and `disconnect` are
application-service operations. The adapter records sequence,
timestamp, direction, byte size, status, status text, initial metadata, and
trailers. It caps event count and retained bytes and reports dropped-event
count. It never retries or reconnects silently.

All metadata values are resolved immediately before a call. Reserved protocol
headers are rejected. Bearer, Basic, and API-key values use secure references;
environment values are resolved with the existing strict resolver. Typed
failures distinguish validation, unresolved variable, missing secret,
authentication, TLS, reflection, deadline, cancellation, transport, and server
status failures. Status messages and trailers are sanitized before presentation
or persistence.
