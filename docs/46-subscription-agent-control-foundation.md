# Subscription Agent Control Foundation

Status: IN PROGRESS. Human UI and subscription agents converge at `AppCommandBus`; handlers then call existing application services. Agents never access Cubits, widgets, Drift, sockets, credentials, or protocol transports directly. Only the fake provider executes in this slice.
