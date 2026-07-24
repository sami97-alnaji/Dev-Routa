# Protobuf descriptor and reflection contract

Status: IN PROGRESS

The client accepts a root `.proto` plus explicitly selected include roots and
resolves only imports beneath those roots. Compilation must use verified
`protoc`, produce a `FileDescriptorSet` with imports included, and preserve the
source/import error path without executing user source. Multiple related proto
files and descriptor-set imports are supported through the same descriptor
registry.

The registry indexes packages, services, methods, messages, enums, fields,
comments, and dependencies. Snapshot hashes detect changes. Its explorer can
drill into request/response types and search fields. Snapshot comparison reports
only conservative candidates: removed service/method/field, field-number or
incompatible-type change, streaming-kind change, oneof-membership change, and
enum-value change.

Reflection runs only after an explicit user action or an approved persisted
setting. It uses generated official reflection stubs to list services and fetch
the file descriptors needed for those services. Disabled, unauthenticated, and
unsupported reflection results are clear terminal states with manual import as
the fallback. Cached reflection results remain browseable offline.

JSON-style input is validated against descriptors before wire encoding. It
handles scalars, enums, nested messages, repeated fields, maps, oneofs, bytes,
and supported well-known timestamp values; unknown fields and type mismatches
return a useful field path. No handwritten `.proto` parser is permitted.
