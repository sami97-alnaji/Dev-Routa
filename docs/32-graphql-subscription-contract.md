# GraphQL subscription contract

The supported WebSocket protocol is `graphql-transport-ws`. The transport implements subprotocol negotiation, connection initialization, acknowledgement timeout, subscribe, next, error, complete, ping/pong, stop, and disconnect. Each connection owns one operation and exposes a typed event stream.

Status: IN PROGRESS. Reconnect policy, persistence, full timeline UI, and complete lifecycle coverage remain pending.
