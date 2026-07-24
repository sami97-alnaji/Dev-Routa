# gRPC architecture

Status: IN PROGRESS

The feature boundary is `lib/features/grpc/`:

```text
gRPC presentation -> Cubit -> application service -> resolver/validator
  -> descriptor or reflection service -> channel adapter -> dynamic codec
  -> sanitized repository/history -> Drift
```

The adapter will use the official native `grpc` package only. A channel is
created after environment and secure references resolve, receives a deadline and
cancellation owner, and is shut down on completion, cancellation, replacement,
or Cubit disposal. Presentation receives immutable state and never owns a
channel or stream subscription.

Descriptor sources are: explicit user `.proto` import compiled with verified
`protoc`, explicitly requested server reflection, and cached snapshots. A
snapshot contains descriptors and hashes only; it never contains metadata,
tokens, certificates, or runtime values. Reflection is not automatic.

TLS is the default. Plaintext is a labelled opt-in. Custom trust material and
mTLS key material are secure references resolved only at channel construction;
database rows hold no credential value. Authority override is an advanced
explicit setting. Compression is exposed only after the adapter supports it
safely.

Windows uses explorer, tabs, editor, metadata/settings, response/timeline and
history panels. Android separates service/method selection, request composition,
settings, response, and streaming composition into focused keyboard-safe views.
