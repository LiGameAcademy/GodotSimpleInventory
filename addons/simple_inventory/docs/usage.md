# Installation and usage

Validated with Godot 4.7.2; Godot 4.5 compatibility has not been tested.

Install this plugin-only repository at addons/simple_inventory:

```sh
git submodule add https://github.com/LiGameAcademy/laoli_simple_inventory.git addons/simple_inventory
git -C addons/simple_inventory checkout <validated-tag-or-commit>
```

Commit .gitmodules and the gitlink. Other developers clone with --recurse-submodules or run git submodule update --init --recursive. Copying the complete plugin directory is also supported.

Enable li_simple_inventory in Project Settings → Plugins, then restart Godot. ItemManager and ItemUseStrategyManager are registered together. Conflicting host Autoloads are preserved; resolve differing implementations before using the plugin.

Create InventoryComponent and EquipmentComponent, configure equipment slots, and pass these components explicitly to InventoryPanel.initialize_components(inventory, equipment, user). Rules work without UI. Configuration Resources are read-only; each GameplayItemInstance or GameplayEquipInstance belongs to one container.

Register host item configurations with ItemManager.register_item_config(). Add instances with inventory.add_item(). A false return leaves the incoming instance and inventory unchanged. items_received(item_id: StringName, quantity: int) reports the original accepted amount once after commit, including complete merges into existing stacks. Observe it for collection objectives; do not use item_added, which only covers new slots. Transfers made through add_item also report receipt; the host decides which sources count toward its objectives.

InventorySnapshot.capture(inventory, equipment) produces version-1 data. Serialize through JSON; restore only after registering item and equipment-slot configurations. restore() validates both containers before replacement. It refreshes UI without emitting acquisition. File paths, disk writes, healing, character attributes, ability grants, model changes and complete game-save policy belong to the host.

Run python tools/run_tests.py --godot /absolute/path/to/godot for a disposable empty-host check. The source project also runs the full rules, UI isolation and editor lifecycle tests.
