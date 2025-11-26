# GodotGear

A lightweight, flexible inventory system plugin for Godot 4.x

![Godot v4.x](https://img.shields.io/badge/Godot-v4.x-blue)
![MIT License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-0.0.1-orange)

English | [简体中文](README_zh.md)

## Overview

GodotGear is a user-friendly inventory system plugin for Godot 4.x that provides a solid foundation for managing items, equipment, and inventory in your games. It's designed to be both simple to use and flexible enough to adapt to various game genres.

## Features

- 🎮 Easy-to-use inventory component system
- 📦 Flexible item management
- ⚔️ Built-in equipment system
- 🎨 Customizable UI widgets
- 🔌 Plugin-based architecture for easy integration
- 📚 Well-documented API
- 🛠️ MIT licensed - free for both personal and commercial use

## Quick Start

1. Copy the `addons/simple_inventory` folder to your Godot project's `addons` directory
2. Enable the plugin in Project Settings -> Plugins
3. Add the `C_Inventory` component to any node in your scene
4. Start using the inventory system!

## Basic Usage

```gdscript
# Add inventory component to a node
@onready var inventory = $C_Inventory

# Create and add an item
var item = Item.new()
inventory.add_item(item)

# Remove an item
inventory.remove_item(0)  # Remove item at slot 0
```

## Documentation

- 📋 [Refactoring Plan](./REFACTORING_PLAN.md) - Detailed architecture refactoring plan and technical roadmap
- 📚 For detailed documentation and examples, please visit our [Wiki](https://github.com/Liweimin0512/GodotGear/wiki) *(Coming soon)*

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
