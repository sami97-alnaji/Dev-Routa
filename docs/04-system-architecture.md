# System architecture

Architecture: **Clean Architecture with feature-based modules**. `core` owns cross-cutting technical concerns; `features` owns user workflows; `shared/models` defines portable domain records; `shared/services` defines contracts.

Features will use `data`, `domain`, and `presentation` sublayers as they are implemented. Widgets only compose UI; execution, persistence, secret access, history, and AI are accessed through interfaces.

The product is local-first. Drift/SQLite stores non-sensitive metadata; the secure-storage abstraction owns secret values.
