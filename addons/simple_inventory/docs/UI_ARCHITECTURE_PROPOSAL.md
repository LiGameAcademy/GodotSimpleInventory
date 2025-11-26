# UI 架构重构提案

## 📋 当前问题

1. **职责不清晰**：`InventoryWidget` 同时管理背包和装备栏
2. **与逻辑不对应**：逻辑有 `InventoryComponent` 和 `EquipmentComponent`，但 UI 只有一个 Widget
3. **可复用性差**：无法单独使用背包或装备栏面板

## 🎯 目标架构

### 1. 组件层级划分

```
UI 组件层级：
├── Widget（面板级）
│   ├── InventoryWidget（背包面板）
│   └── EquipmentWidget（装备栏面板）
│
├── Slot（槽位级）
│   ├── ItemSlot（物品槽位）
│   └── EquipSlot（装备槽位，继承 ItemSlot）
│
├── Tile（显示级）
│   └── ItemTile（物品显示瓦片）
│
└── Tip（提示级）
    └── ItemTip（物品提示）
```

### 2. 建议的目录结构

```
addons/simple_inventory/ui/
├── widgets/
│   ├── inventory_widget.gd
│   ├── inventory_widget.tscn
│   ├── equipment_widget.gd
│   └── equipment_widget.tscn
│
├── slots/
│   ├── item_slot.gd
│   ├── item_slot.tscn
│   ├── equip_slot.gd
│   └── equip_slot.tscn
│
├── tiles/
│   ├── item_tile.gd
│   └── item_tile.tscn
│
└── tips/
    ├── item_tip.gd
    └── item_tip.tscn
```

## 🔄 重构方案

### 方案 A：完全拆分（推荐）

**优点**：
- 职责清晰，与逻辑组件一一对应
- 高度可复用，可独立使用
- 易于维护和扩展

**结构**：
- `InventoryWidget` → 对应 `InventoryComponent`
- `EquipmentWidget` → 对应 `EquipmentComponent`
- 可选的组合面板（如 `InventoryPanel`）组合两者

### 方案 B：保持组合，但内部拆分

**优点**：
- 保持现有 API 兼容
- 内部实现更清晰

**缺点**：
- 仍然耦合，无法独立使用

## 💡 推荐方案：方案 A

### 1. 创建独立的 Widget

#### InventoryWidget（背包面板）
- 职责：管理背包物品显示、筛选、整理
- 依赖：`InventoryComponent` 或 `C_Inventory`
- 功能：
  - 物品网格显示
  - 分类筛选（TabBar）
  - 整理按钮
  - 分解按钮

#### EquipmentWidget（装备栏面板）
- 职责：管理装备槽位显示
- 依赖：`EquipmentComponent` 或 `C_Inventory`
- 功能：
  - 装备槽位布局
  - 装备显示
  - 装备交互

### 2. Slot 层级优化

**当前结构**：
```
ItemSlot
└── ItemTile (子节点)
```

**建议**：
- 保持当前结构（ItemTile 作为 ItemSlot 的子节点是合理的）
- 但考虑让 ItemTile 更独立，可以单独使用

**可选方案**：
```
ItemSlot
├── ItemTile (可选，用于显示)
└── EquipSlot (继承 ItemSlot)
    └── ItemTile (继承，覆盖显示逻辑)
```

### 3. Tile 层级评估

**当前设计**：`ItemTile` 作为 `ItemSlot` 的子节点

**优点**：
- 结构清晰，Slot 管理交互，Tile 管理显示
- 符合组合模式

**可改进点**：
- 考虑让 `ItemTile` 可以独立使用（如用于快捷栏）
- 添加 `EquipTile` 用于装备特殊显示（如耐久度条）

### 4. Tip 层级评估

**当前设计**：`ItemTip` 作为 Tooltip 使用

**评估**：✅ 合理
- Tooltip 是独立的 UI 元素
- 通过 `_make_custom_tooltip` 机制使用
- 无需改动

## 📐 具体实现建议

### 1. InventoryWidget 接口

```gdscript
extends Control
class_name InventoryWidget

## 背包组件引用
var inventory_component: InventoryComponent = null

## 初始化
func initialize(component: InventoryComponent) -> void:
    inventory_component = component
    # 连接信号
    # 初始化显示

## 显示/隐藏
func show_inventory() -> void:
    show()

func hide_inventory() -> void:
    hide()
```

### 2. EquipmentWidget 接口

```gdscript
extends Control
class_name EquipmentWidget

## 装备组件引用
var equipment_component: EquipmentComponent = null

## 初始化
func initialize(component: EquipmentComponent) -> void:
    equipment_component = component
    # 连接信号
    # 初始化槽位显示

## 显示/隐藏
func show_equipment() -> void:
    show()

func hide_equipment() -> void:
    hide()
```

### 3. 可选：组合面板

```gdscript
extends Control
class_name InventoryPanel

## 组合面板，包含背包和装备栏
@onready var inventory_widget: InventoryWidget = $InventoryWidget
@onready var equipment_widget: EquipmentWidget = $EquipmentWidget

func initialize(inventory: C_Inventory) -> void:
    inventory_widget.initialize(inventory.inventory_component)
    equipment_widget.initialize(inventory.equipment_component)
```

## ✅ 层级划分评估

### Slot 层级
- ✅ **ItemSlot / EquipSlot**：继承关系合理
- ✅ **ItemTile 作为子节点**：符合组合模式，职责清晰

### Tile 层级
- ✅ **ItemTile**：作为 Slot 的子节点合理
- 💡 **建议**：考虑添加 `EquipTile` 用于装备特殊显示

### Tip 层级
- ✅ **ItemTip**：作为 Tooltip 使用，设计合理

## 🎯 总结

### 推荐的重构步骤

1. **拆分 Widget**
   - 创建 `InventoryWidget`（独立）
   - 创建 `EquipmentWidget`（独立）
   - 可选：创建 `InventoryPanel`（组合两者）

2. **优化目录结构**
   - `ui/widgets/` - 面板级组件
   - `ui/slots/` - 槽位级组件
   - `ui/tiles/` - 显示级组件
   - `ui/tips/` - 提示级组件

3. **保持 Slot/Tile/Tip 层级**
   - 当前设计合理，无需大改
   - 可考虑添加 `EquipTile` 用于装备特殊显示

### 优势

1. **职责清晰**：每个 Widget 对应一个逻辑组件
2. **高度可复用**：可以单独使用背包或装备栏
3. **易于维护**：修改一个面板不影响另一个
4. **符合插件设计**：提供独立的面板，用户按需组合

