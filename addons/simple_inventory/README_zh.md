# GodotGear

一个轻量级、灵活的 Godot 4.x 背包系统插件

![Godot v4.x](https://img.shields.io/badge/Godot-v4.x-blue)
![MIT License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-0.0.1-orange)

[English](README.md) | 简体中文

## 概述

GodotGear 是一个为 Godot 4.x 开发的用户友好的背包系统插件，为游戏中的物品、装备和背包管理提供了坚实的基础。它的设计既简单易用，又足够灵活，可以适应各种不同类型的游戏。

## 特性

- 🎮 简单易用的背包组件系统
- 📦 灵活的物品管理
- ⚔️ 内置装备系统
- 🎨 可自定义的UI组件
- 🔌 基于插件架构，易于集成
- 📚 完善的API文档
- 🛠️ MIT许可证 - 可自由用于个人和商业项目

## 快速开始

1. 将 `addons/simple_inventory` 文件夹复制到你的 Godot 项目的 `addons` 目录中
2. 在项目设置中启用插件（Project Settings -> Plugins）
3. 将 `C_Inventory` 组件添加到场景中的任意节点
4. 开始使用背包系统！

## 基本用法

```gdscript
# 添加背包组件到节点
@onready var inventory = $C_Inventory

# 创建并添加物品
var item = Item.new()
inventory.add_item(item)

# 移除物品
inventory.remove_item(0)  # 移除槽位0的物品
```

## 文档

- 📋 [重构计划文档](./REFACTORING_PLAN.md) - 详细的架构重构计划和技术路线图
- 📚 详细文档和示例请访问我们的 [Wiki](https://github.com/Liweimin0512/GodotGear/wiki) *（即将推出）*

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
