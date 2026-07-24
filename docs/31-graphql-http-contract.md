# GraphQL HTTP contract

Requests carry `query`, optional `operationName`, `variables`, and `extensions`. Queries may use GET; mutations and subscriptions are rejected from incompatible transports before network execution. Responses distinguish data, typed GraphQL errors, extensions, HTTP metadata, malformed envelopes, and transport failures.

Status: COMPLETE. Environment/auth resolution, bounded response tooling, diagnostics, and history integration are implemented; see [the repository closure](37-phase4-repository-closure.md).
