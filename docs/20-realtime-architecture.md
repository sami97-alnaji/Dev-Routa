# Realtime architecture

The `features/realtime` feature owns the protocol-neutral session model, transport adapters, persistence repository, Cubit, and responsive screen. Widgets do not open sockets directly. Each `RealtimeSessionCubit` owns one isolated session; desktop tabs use sibling Cubits with independent resolvers and streams. Messages are bounded by `maxEvents`, HTTP stream updates are batched, dropped-event counts are visible, and subscriptions close deterministically.

`RealtimeTransport` resolves active-environment variables and secure-storage references immediately before connection. Unresolved variables or unavailable secret references block execution. Runtime secrets are held only by the session resolver, redact reflected server content, and are cleared on transport cleanup. Configurations, drafts, history, diagnostics, AI previews, clipboard output, and exports contain no resolved secret values. Binary payload bytes are explicitly not retained.
