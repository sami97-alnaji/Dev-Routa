# GraphQL schema introspection and cache

Introspection is explicit and uses the configured endpoint/auth path. The current schema tool parses bounded introspection payloads into typed types, fields, arguments, enum values, wrappers, roots, descriptions, and deprecation metadata. Snapshots receive a stable SHA-256 hash and can be compared conservatively.

Status: COMPLETE. Snapshot persistence, offline restoration, Schema Explorer, comparison, and operation skeleton generation are implemented; see [the repository closure](37-phase4-repository-closure.md).
