# Local data and history policy

Drift/SQLite schema version 4 stores workspaces, collections, one-level folders, complete non-secret request configuration, request drafts, environments, enabled/ordered variables, immutable history metadata, retention settings, and Phase 3 non-secret metadata. Secure values remain in platform secure storage; SQLite contains references only.

The migration chain upgrades versions 1, 2, and 3 without resetting data. Workspace deletion cascades through owned collections, folders, requests, drafts, environments, variables, realtime metadata, and secure references. Deleting a folder safely moves requests and children upward; history remains immutable until explicit deletion or retention cleanup.

Response previews are bounded by the persisted workspace byte limit. History caps response bodies at 256 KiB and removes sensitive headers, cookies, named secret shapes, and exact runtime secret values used for the request. Safe clipboard and JSON export apply the same redaction policy.
