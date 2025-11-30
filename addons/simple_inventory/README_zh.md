# GodotGear

一个轻量级、灵活的 Godot 4.x 背包系统插件

![Godot v4.x](https://img.shields.io/badge/Godot-v4.x-blue)
![MIT License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-0.0.1-orange)

[English](README.md) | 简体中文

## 概述

`simple_inventory` 是一个为 Godot 4.x 开发的用户友好的背包系统插件，为游戏中的物品、装备和背包管理提供了坚实的基础。它的设计既简单易用，又足够灵活，可以适应各种不同类型的游戏。

## 特性

- 🎮 **组件化架构** - 清晰的背包和装备组件分离
- 📦 **灵活的物品管理** - 支持可堆叠物品、物品类型和自定义属性
- ⚔️ **内置装备系统** - 功能完整的装备管理，支持槽位配置
- 🎨 **可自定义的UI组件** - 模块化UI组件（InventoryWidget、EquipmentWidget、InventoryPanel）
- 🔄 **运行时扩容** - 动态调整背包容量
- 🔀 **自定义排序** - 可替换的排序系统，默认提供基于类型的排序
- 🎯 **策略模式** - 可扩展的物品使用系统（装备、消耗品等）
- 📊 **基于资源的配置** - 物品类型、装备类型和物品作为资源
- 🔌 **插件化架构** - 易于集成到任何 Godot 4.x 项目
- 📚 **完善的API文档** - 详细的文档和示例
- 🛠️ **MIT许可证** - 可自由用于个人和商业项目

## 快速开始

1. 将 `addons/simple_inventory` 文件夹复制到你的 Godot 项目的 `addons` 目录中
2. 在项目设置中启用插件（Project Settings -> Plugins）
3. 将 `C_Inventory` 组件添加到场景中的任意节点
4. 开始使用背包系统！

## 基本用法

### 设置

```gdscript
# 从节点获取背包组件
@onready var inventory_component = $InventoryComponent

# 或使用静态辅助方法
var inventory_component = InventoryComponent.get_inventory_component(player)
```

### 创建和添加物品

```gdscript
# 方法1：通过ID创建物品实例（推荐）
var item_instance = ItemManager.create_item_instance("potion_health", 5)
inventory_component.add_item(item_instance)

# 方法2：直接通过ID添加物品
inventory_component.add_item_by_id("potion_health", 5)

# 方法3：手动创建物品实例
var item_config = ItemManager.get_item_config("potion_health")
var item_instance = GameplayItemInstance.new(item_config, 5)
inventory_component.add_item(item_instance)
```

### 管理物品

```gdscript
# 移除指定槽位的物品
inventory_component.remove_item(0)

# 通过ID和数量移除物品
inventory_component.remove_item_by_id("potion_health", 3)

# 检查是否有足够的物品
if inventory_component.has_item("potion_health", 5):
    print("有足够的药水！")

# 获取物品数量
var count = inventory_component.get_item_count("potion_health")

# 获取指定槽位的物品
var item = inventory_component.get_item(0)
```

### 使用物品

```gdscript
# 使用指定槽位的物品（user 默认为组件的父节点）
inventory_component.use_item(0)

# 使用物品并指定使用者
inventory_component.use_item(0, player)
```

### 整理背包

```gdscript
# 整理物品（合并相同物品并排序）
inventory_component.pack_items()

# 按类型排序
inventory_component.sort_items_by_type()
```

### 运行时扩容

```gdscript
# 扩容背包
inventory_component.set_max_slot_count(30)

# 缩容背包（安全模式 - 如果会丢失物品则失败）
inventory_component.set_max_slot_count(20, false)

# 强制缩容（会移除超出部分的物品）
inventory_component.set_max_slot_count(20, true)
```

### 自定义排序

默认排序规则按以下优先级：
1. `item_type.sort_order`（物品类型优先级）
2. `equip_type.sort_order`（如果都是装备，装备类型优先级）
3. `gameplay_item.sort_order`（物品优先级）
4. `item_id`（最终按ID排序）

```gdscript
# 创建自定义排序器
extends InventorySorter
class_name MyCustomSorter

func sort(items: Array[GameplayItemInstance]) -> Array[GameplayItemInstance]:
    # 你的自定义排序逻辑
    return items

# 设置自定义排序器
var custom_sorter = MyCustomSorter.new()
inventory_component.set_sorter(custom_sorter)
```

## 架构

插件采用组件化架构：

- **InventoryComponent** - 管理物品存储、排序和合并
- **EquipmentComponent** - 处理装备槽位和已装备物品
- **ItemManager** - 单例，管理物品配置和类型
- **ItemUseStrategyManager** - 管理物品使用策略（装备、消耗品等）
- **UI组件** - 独立的背包和装备显示组件

### 核心类

- `GameplayItem` - 基础物品配置资源
- `GameplayEquip` - 装备物品配置（继承自 GameplayItem）
- `GameplayItemInstance` - 运行时物品实例，包含数量和耐久度
- `GameplayEquipInstance` - 运行时装备实例（继承自 GameplayItemInstance）
- `GameplayItemType` - 物品类型/分类配置
- `GameplayEquipType` - 装备类型配置

## 文档

- 📋 [重构计划文档](./REFACTORING_PLAN.md) - 详细的架构重构计划和技术路线图
- 📋 [手动测试用例](./docs/MANUAL_TEST_CASES.md) - 全面的手动测试指南
- 📚 详细文档和示例请访问我们的 [Wiki](https://github.com/LiGameAcademy/GodotSimpleInventory/wiki) *（即将推出）*

## 贡献

欢迎贡献！你可以：

- 报告问题
- 提出新功能建议
- 提交代码
- 改进文档

## 许可证

本项目采用双重许可：

1. **源代码**：源代码采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件。

2. **素材资源**：所有素材资源（包括但不限于 `assets` 目录中的图片、音效和其他媒体文件）**不**适用于 MIT 许可证。这些资源的所有权利均由其各自的所有者保留。未经版权所有者的明确许可，你不得使用、复制、修改、合并、发布、分发、再许可或销售这些资源。

## 致谢

由 old_lee 创建和维护

---

为 Godot 社区用 ❤️ 制作
