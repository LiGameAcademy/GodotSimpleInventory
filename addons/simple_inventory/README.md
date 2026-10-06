# GodotGear

Unreleased pilot: tested on Godot 4.7.2. Restart Godot after first enabling the plugin. Existing same-name singletons are preserved. See [migration notes](docs/pilot_migration.md) and [changelog](../../CHANGELOG.md); the examples below describe the earlier release.

A lightweight, flexible inventory system plugin for Godot 4.x

![Godot v4.x](https://img.shields.io/badge/Godot-v4.x-blue)
![MIT License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-0.0.1-orange)

English | [简体中文](README_zh.md)

## Overview

`SimpleInventory` is a user-friendly inventory system plugin for Godot 4.x that provides a solid foundation for managing items, equipment, and inventory in your games. It's designed to be both simple to use and flexible enough to adapt to various game genres.

## Features

- 🎮 **Component-based Architecture** - Clean separation of inventory and equipment components
- 📦 **Flexible Item Management** - Support for stackable items, item types, and custom properties
- ⚔️ **Built-in Equipment System** - Full-featured equipment management with slot configuration
- 🎨 **Customizable UI Widgets** - Modular UI components (InventoryWidget, EquipmentWidget, InventoryPanel)
- 🔄 **Runtime Expansion** - Dynamically adjust inventory capacity at runtime
- 🔀 **Custom Sorting** - Replaceable sorting system with default type-based sorting
- 🎯 **Strategy Pattern** - Extensible item usage system (equip, consumable, etc.)
- 📊 **Resource-based Configuration** - Item types, equip types, and items as resources
- 🔌 **Plugin-based Architecture** - Easy integration into any Godot 4.x project
- 📚 **Well-documented API** - Comprehensive documentation and examples
- 🛠️ **MIT Licensed** - Free for both personal and commercial use

## Quick Start

1. Copy the `addons/simple_inventory` folder to your Godot project's `addons` directory
2. Enable the plugin in Project Settings -> Plugins
3. Add the `C_Inventory` component to any node in your scene
4. Start using the inventory system!

## Basic Usage

### Setting Up

```gdscript
# Get the inventory component from a node
@onready var inventory_component = $InventoryComponent

# Or use the static helper method
var inventory_component = InventoryComponent.get_inventory_component(player)
```

### Creating and Adding Items

```gdscript
# Method 1: Create item instance by ID (recommended)
var item_instance = ItemManager.create_item_instance("potion_health", 5)
inventory_component.add_item(item_instance)

# Method 2: Add item by ID directly
inventory_component.add_item_by_id("potion_health", 5)

# Method 3: Create item instance manually
var item_config = ItemManager.get_item_config("potion_health")
var item_instance = GameplayItemInstance.new(item_config, 5)
inventory_component.add_item(item_instance)
```

### Managing Items

```gdscript
# Remove item at slot index
inventory_component.remove_item(0)

# Remove item by ID and quantity
inventory_component.remove_item_by_id("potion_health", 3)

# Check if has enough items
if inventory_component.has_item("potion_health", 5):
    print("Has enough potions!")

# Get item count
var count = inventory_component.get_item_count("potion_health")

# Get item at slot
var item = inventory_component.get_item(0)
```

### Using Items

```gdscript
# Use item at slot (user defaults to component's parent)
inventory_component.use_item(0)

# Use item with specific user
inventory_component.use_item(0, player)
```

### Organizing Inventory

```gdscript
# Pack items (merge similar items and sort)
inventory_component.pack_items()

# Sort items by type
inventory_component.sort_items_by_type()
```

### Runtime Expansion

```gdscript
# Expand inventory capacity
inventory_component.set_max_slot_count(30)

# Shrink inventory (safe mode - fails if items would be lost)
inventory_component.set_max_slot_count(20, false)

# Force shrink (removes excess items)
inventory_component.set_max_slot_count(20, true)
```

### Custom Sorting

The default sorting follows this priority:
1. `item_type.sort_order` (item type priority)
2. `equip_type.sort_order` (if both are equipment, equipment type priority)
3. `gameplay_item.sort_order` (item priority)
4. `item_id` (final sort by ID)

```gdscript
# Create custom sorter
extends InventorySorter
class_name MyCustomSorter

func sort(items: Array[GameplayItemInstance]) -> Array[GameplayItemInstance]:
    # Your custom sorting logic
    return items

# Set custom sorter
var custom_sorter = MyCustomSorter.new()
inventory_component.set_sorter(custom_sorter)
```

## Architecture

The plugin follows a component-based architecture:

- **InventoryComponent** - Manages item storage, sorting, and merging
- **EquipmentComponent** - Handles equipment slots and equipped items
- **ItemManager** - Singleton for managing item configurations and types
- **ItemUseStrategyManager** - Manages item usage strategies (equip, consumable, etc.)
- **UI Widgets** - Separate widgets for inventory and equipment display

### Core Classes

- `GameplayItem` - Base item configuration resource
- `GameplayEquip` - Equipment item configuration (extends GameplayItem)
- `GameplayItemInstance` - Runtime item instance with quantity and durability
- `GameplayEquipInstance` - Runtime equipment instance (extends GameplayItemInstance)
- `GameplayItemType` - Item type/category configuration
- `GameplayEquipType` - Equipment type configuration

## Documentation

- 📋 [Refactoring Plan](./REFACTORING_PLAN.md) - Detailed architecture refactoring plan and technical roadmap
- 📋 [Manual Test Cases](./docs/MANUAL_TEST_CASES.md) - Comprehensive manual testing guide
- 📚 For detailed documentation and examples, please visit our [Wiki](https://github.com/LiGameAcademy/GodotSimpleInventory/wiki) *(Coming soon)*

## Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## License

This project is dual-licensed:

1. **Source Code**: The source code is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

2. **Assets**: All assets (including but not limited to images, sounds, and other media files in the `assets` directory) are NOT covered by the MIT license. All rights to these assets are reserved by their respective owners. You may NOT use, copy, modify, merge, publish, distribute, sublicense, and/or sell these assets without explicit permission from the copyright holders.

## Credits

Created and maintained by old_lee

---

Made with ❤️ for the Godot community
