# GraphQL architecture

The document editor keeps the exact user source. `gql` parses it into an AST for validation and operation discovery; normalized printing is optional. HTTP execution and subscription transport are services, not widget-owned networking. Secure values are resolved only at execution/connection time and typed failures cross the presentation boundary.

Status: COMPLETE. Persistence and workspace composition are implemented; final evidence is recorded in [the repository closure](37-phase4-repository-closure.md).
