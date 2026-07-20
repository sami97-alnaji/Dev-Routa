# GraphQL HTTP contract

Requests carry `query`, optional `operationName`, `variables`, and `extensions`. Queries may use GET; mutations and subscriptions are rejected from incompatible transports before network execution. Responses distinguish data, typed GraphQL errors, extensions, HTTP metadata, malformed envelopes, and transport failures.

Status: IN PROGRESS. Environment interpolation, full auth composition, bounded UI response tooling, and complete history integration remain pending.
