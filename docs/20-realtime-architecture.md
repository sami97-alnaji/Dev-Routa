# Realtime architecture

The `features/realtime` feature owns the protocol-neutral session model, transport adapters, persistence repository, Cubit, and responsive screen. Widgets do not open sockets directly. `RealtimeSessionCubit` owns a single isolated session, bounds messages to `maxEvents`, supports cancellation, and closes subscriptions deterministically.

`RealtimeTransport` resolves variables and secure-storage references immediately before creating a connection. Resolved values are not cached in configurations, drafts, history, diagnostics, or exports. A session records only sanitized message text and metadata; binary payload bytes are explicitly not retained.
