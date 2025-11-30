# GodotSimpleInventory

一个基于 Godot 4.5 开发的简单库存系统项目，旨在演示如何使用 Godot 开发复杂的 UI 模块并用于教学。

![Godot v4.5](https://img.shields.io/badge/Godot-v4.5-blue)
![MIT License](https://img.shields.io/badge/license-MIT-green)

## 📖 项目简介

本项目是一个完整的库存系统实现，包含：

- **插件系统**：可复用的库存系统插件（`addons/simple_inventory`）
- **示例项目**：完整的使用示例和测试场景
- **单元测试**：全面的单元测试覆盖
- **详细文档**：架构设计、重构计划和使用文档

本项目适合：
- 🎓 学习 Godot 4.x 插件开发
- 📚 学习组件化架构设计
- 🔧 学习 UI 系统开发
- 🧪 学习单元测试实践

## ✨ 主要特性

### 插件特性

- 🎮 **组件化架构** - 清晰的背包和装备组件分离
- 📦 **灵活的物品管理** - 支持可堆叠物品、物品类型和自定义属性
- ⚔️ **内置装备系统** - 功能完整的装备管理，支持槽位配置
- 🎨 **可自定义的UI组件** - 模块化UI组件（InventoryWidget、EquipmentWidget、InventoryPanel）
- 🔄 **运行时扩容** - 动态调整背包容量
- 🔀 **自定义排序** - 可替换的排序系统，默认提供基于类型的排序
- 🎯 **策略模式** - 可扩展的物品使用系统（装备、消耗品等）
- 📊 **基于资源的配置** - 物品类型、装备类型和物品作为资源

### 项目特性

- 📝 **完整示例** - 包含完整的使用示例和测试场景
- 🧪 **单元测试** - 全面的单元测试覆盖
- 📚 **详细文档** - 架构设计、重构计划和使用文档
- 🎯 **教学导向** - 代码注释详细，适合学习和教学

## 🚀 快速开始

### 环境要求

- Godot 4.5 或更高版本
- 支持 GDScript 的项目

### 安装步骤

1. **克隆或下载项目**
   ```bash
   git clone <repository-url>
   cd godot-simple-inventory
   ```

2. **打开项目**
   - 使用 Godot 4.5 打开项目
   - 项目会自动检测插件

3. **启用插件**
   - 打开 `Project Settings -> Plugins`
   - 启用 `Simple Inventory` 插件

4. **运行示例**
   - 打开 `main.tscn` 场景
   - 运行项目查看示例

## 📁 项目结构

```
godot-simple-inventory/
├── addons/
│   └── simple_inventory/          # 库存系统插件
│       ├── assets/                # 资源文件（纹理、音效等）
│       ├── docs/                  # 插件文档
│       ├── scripts/               # 插件脚本
│       │   ├── components/        # 组件（InventoryComponent, EquipmentComponent）
│       │   ├── data/              # 数据类（GameplayItem, GameplayEquip等）
│       │   ├── managers/          # 管理器（ItemManager, ItemUseStrategyManager）
│       │   ├── services/          # 服务类（InventorySorter, ItemMerger等）
│       │   └── strategies/       # 策略类（ItemUseStrategy等）
│       ├── ui/                    # UI组件
│       │   ├── widgets/           # 主要UI组件
│       │   ├── slots/             # 槽位组件
│       │   ├── tiles/             # 物品显示组件
│       │   └── tips/              # 提示组件
│       ├── README.md              # 插件README（英文）
│       └── README_zh.md           # 插件README（中文）
├── tests/                         # 单元测试
│   ├── test_runner.gd             # 测试运行器
│   ├── test_main.gd               # 测试主入口
│   └── test_*.gd                  # 各模块测试
├── docs/                          # 项目文档
│   └── MANUAL_TEST_CASES.md       # 手动测试用例
├── main.gd                        # 示例主脚本
├── main.tscn                      # 示例主场景
├── entity/                        # 示例实体
│   └── player.tscn                # 玩家实体示例
└── README.md                      # 本文件
```

## 📖 使用指南

### 插件使用

详细的插件使用说明请参考：
- [插件 README（中文）](./addons/simple_inventory/README_zh.md)
- [插件 README（English）](./addons/simple_inventory/README.md)

### 基本示例

```gdscript
# 获取背包组件
var inventory_component = InventoryComponent.get_inventory_component(player)

# 添加物品
inventory_component.add_item_by_id("potion_health", 5)

# 使用物品
inventory_component.use_item(0)

# 整理背包
inventory_component.pack_items()

# 运行时扩容
inventory_component.set_max_slot_count(30)
```

### 运行测试

1. **运行单元测试**
   - 打开 `tests/test_main.tscn` 场景
   - 运行场景，查看控制台输出

2. **手动测试**
   - 运行 `main.tscn` 场景
   - 使用控制台命令进行测试
   - 参考 [手动测试用例](./docs/MANUAL_TEST_CASES.md)

### 控制台命令

在示例场景中，可以使用以下命令：

- `add_item <item_id> <quantity>` - 添加物品
- `remove_item <slot_index>` - 移除物品
- `remove_item_by_id <item_id> <quantity>` - 通过ID移除物品
- `pack_inventory` - 整理背包
- `list_inventory` - 列出背包物品
- `get_item_count <item_id>` - 获取物品数量
- `equip_item <item_id>` - 装备物品
- `unequip_item <slot_id>` - 卸载装备
- `list_equipment` - 列出装备
- `expand_inventory <new_count> [force]` - 扩容/缩容背包

## 📚 文档

### 插件文档

- [插件 README（中文）](./addons/simple_inventory/README_zh.md)
- [插件 README（English）](./addons/simple_inventory/README.md)
- [重构计划](./addons/simple_inventory/docs/REFACTORING_PLAN.md)
- [重构步骤](./addons/simple_inventory/docs/REFACTORING_STEPS.md)
- [UI架构提案](./addons/simple_inventory/docs/UI_ARCHITECTURE_PROPOSAL.md)
- [装备类型与槽位配置](./addons/simple_inventory/docs/EQUIP_TYPE_VS_SLOT_CONFIG.md)

### 项目文档

- [手动测试用例](./addons/simple_inventory/docs/MANUAL_TEST_CASES.md)

## 🧪 测试

### 单元测试

项目包含完整的单元测试，覆盖以下模块：

- ✅ `GameplayItemInstance` - 物品实例测试
- ✅ `ItemManager` - 物品管理器测试
- ✅ `InventoryComponent` - 背包组件测试
- ✅ `ItemMerger` - 物品合并器测试
- ✅ `InventorySorter` - 排序器测试
- ✅ `EquipmentComponent` - 装备组件测试

运行测试：
```bash
# 在 Godot 编辑器中打开 tests/test_main.tscn 并运行
```

### 手动测试

详细的手动测试用例请参考 [手动测试用例文档](./docs/MANUAL_TEST_CASES.md)

## 🏗️ 架构设计

### 组件架构

- **InventoryComponent** - 管理物品存储、排序和合并
- **EquipmentComponent** - 处理装备槽位和已装备物品
- **ItemManager** - 单例，管理物品配置和类型
- **ItemUseStrategyManager** - 管理物品使用策略

### 设计模式

- **组件模式** - 实体通过组件组合功能
- **策略模式** - 物品使用策略可扩展
- **单例模式** - 全局管理器使用 AutoLoad
- **外观模式** - C_Inventory 提供统一接口

### 核心类

- `GameplayItem` - 基础物品配置资源
- `GameplayEquip` - 装备物品配置
- `GameplayItemInstance` - 运行时物品实例
- `GameplayEquipInstance` - 运行时装备实例
- `GameplayItemType` - 物品类型配置
- `GameplayEquipType` - 装备类型配置

## 🤝 贡献

欢迎贡献！你可以：

- 🐛 报告问题
- 💡 提出新功能建议
- 📝 提交代码改进
- 📚 改进文档

## 📄 许可证

本项目采用双重许可：

1. **源代码**：源代码采用 MIT 许可证 - 详见 [LICENSE](./LICENSE) 文件。

2. **素材资源**：所有素材资源（包括但不限于 `assets` 目录中的图片、音效和其他媒体文件）**不**适用于 MIT 许可证。这些资源的所有权利均由其各自的所有者保留。未经版权所有者的明确许可，你不得使用、复制、修改、合并、发布、分发、再许可或销售这些资源。

## 👏 致谢

- 由 old_lee 创建和维护
- 为 Godot 社区用 ❤️ 制作

## 📝 更新日志

### 最新版本

- ✅ 完成组件化架构重构
- ✅ 实现运行时扩容功能
- ✅ 实现自定义排序系统
- ✅ 完善单元测试覆盖
- ✅ 更新文档和示例

---

**注意**：本项目主要用于教学和演示目的。在生产环境中使用前，请根据实际需求进行适当的调整和测试。
