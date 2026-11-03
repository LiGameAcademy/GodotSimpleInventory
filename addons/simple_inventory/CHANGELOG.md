# Changelog

## 0.0.2

- Atomic item acquisition, stack merging, container ownership and safe equipment replacement.
- Independent inventory/equipment state, explicit UI binding and version-1 JSON snapshots.
- Added items_received(item_id, quantity), emitted after successful acquisition including full merges; restore emits no acquisition.
- Standalone installation contracts for Godot 4.7.2.
- Plugin-only distribution generated from the source project's addons/simple_inventory directory.
