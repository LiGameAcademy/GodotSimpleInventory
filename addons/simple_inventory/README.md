# LaoLi Simple Inventory

[简体中文](README_zh.md) · [Usage](docs/usage.md) · [MIT code license](LICENSE) · [Asset credits](THIRD_PARTY_NOTICES.md)

Reusable inventory and equipment components for Godot: stackable item instances, container ownership, equipment slots, safe replacement, independent UI panels and version-1 JSON snapshots.

> For more Godot learning resources and to support future development, visit [LiGameAcademy on Patreon](https://www.patreon.com/cw/LiGameAcademy).

Validated with **Godot 4.7.2**. Godot 4.5 has not been tested. This repository root is the plugin directory, not an example game.

## Install

```sh
git submodule add https://github.com/LiGameAcademy/laoli_simple_inventory.git addons/simple_inventory
git -C addons/simple_inventory checkout <validated-tag-or-commit>
```

Commit the fixed pointer. Other developers use recursive checkout. Enable li_simple_inventory, then restart Godot so both Autoloads load together. Copying the whole plugin directory also works. Existing same-name host Autoloads are preserved.

## Integrate

Create InventoryComponent and EquipmentComponent, configure slots and item Resources, then bind InventoryPanel with initialize_components(inventory, equipment, user). The rules do not require UI. Host code implements healing, attributes, abilities, models and file persistence.

Listen to items_received(item_id, quantity) for successful receipts, including fully merged stacks. Failed additions and snapshot restores do not emit acquisition. See [usage](docs/usage.md) for transfer semantics and snapshot registration requirements.

## Source and validation

The authoritative source is [GodotSimpleInventory](https://github.com/LiGameAcademy/GodotSimpleInventory), under addons/simple_inventory. This distribution is generated with git subtree split; changes go through the source project, not a second independently maintained implementation.

Run python tools/run_tests.py --godot <executable> for isolated-host contracts. The source project also provides full core, UI and editor lifecycle tests. Prototype visuals and interaction preferences still need project-specific acceptance. Code is MIT; bundled assets retain their own licenses.
