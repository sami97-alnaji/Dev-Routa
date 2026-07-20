# GraphQL schema introspection and cache

Introspection is explicit and uses the configured endpoint/auth path. The current schema tool parses bounded introspection payloads into typed types, fields, arguments, enum values, wrappers, roots, descriptions, and deprecation metadata. Snapshots receive a stable SHA-256 hash and can be compared conservatively.

Status: IN PROGRESS. Local snapshot persistence, retention, offline explorer UX, and denial-state UI remain pending.
