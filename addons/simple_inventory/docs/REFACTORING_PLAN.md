# 重构计划文档

## 📋 概述

本文档详细记录了 `godot-simple-inventory` 插件的重构计划，旨在提升代码质量、架构清晰度和系统灵活性。

---

## 🎯 重构目标

1. **架构优化**：清晰的职责分离和分层架构
2. **代码质量**：完整的类型注解、文档注释和错误处理
3. **设计模式**：合理运用组件模式、策略模式、工厂模式等
4. **扩展性**：支持更灵活的物品类型和装备系统
5. **可维护性**：统一的命名规范和文件组织

---

## 🔄 核心变更

### 一、命名规范调整

#### 1.1 类名重命名
- `Item` → `GameplayItem`（游戏物品资源）
- `Equip` → `GameplayEquip`（游戏装备资源）
- `C_Inventory` → `InventoryComponent`（保持 `C_Inventory` 作为别名以向后兼容）

#### 1.2 命名规范统一
- **组件类**：统一使用 `Component` 后缀
  - `InventoryComponent`
  - `EquipmentComponent`
- **UI 组件**：保持现有命名
  - `InventoryWidget`
  - `ItemSlot`
  - `EquipSlot`
  - `ItemTile`
  - `ItemTip`

---

### 二、装备类型系统重构

#### 2.1 从枚举到 Resource

**当前实现**：
```gdscript
# equip.gd
enum EQUIP_TYPE {
    CHEST,
    FEET,
    HEAD,
    LEGS,
    NECKLACE,
    RING,
    WEAPON,
}
```

**重构后**：
```gdscript
# EquipType.gd
extends Resource
class_name EquipType

@export var id: StringName = ""
@export var display_name: String = ""
@export var icon: Texture2D = null
@export var slot_texture: Texture2D = null
# 可扩展的属性...
```

**优势**：
- 支持运行时动态创建装备类型
- 可在编辑器中配置装备类型属性
- 更易于扩展和本地化
- 支持装备类型的继承和组合

#### 2.2 装备槽配置

装备槽配置也改为 Resource：
```gdscript
# EquipSlotConfig.gd
extends Resource
class_name EquipSlotConfig

@export var slot_name: StringName = ""
@export var equip_type: EquipType = null
@export var allow_multiple: bool = false  # 是否允许多个（如戒指）
```

---

### 三、配置资源与状态实例分离

#### 3.1 资源类（配置数据）

**GameplayItem**（配置资源）：
```gdscript
# GameplayItem.gd
extends Resource
class_name GameplayItem

## 物品唯一标识符
@export var item_id: StringName = ""

## 物品基础属性（配置数据）
@export var name: String = "道具名称"
@export var icon: Texture2D = null
@export var description: String = "道具描述"
@export var category: ITEM_TYPE = ITEM_TYPE.NONE
@export var max_stack: int = 1
@export var weight: float = 0.0
@export var base_attributes: Dictionary = {}

enum ITEM_TYPE {
    NONE,
    CONSUMABLE,
    EQUIPMENT,
    MATERIAL,
}
```

**GameplayEquip**（配置资源）：
```gdscript
# GameplayEquip.gd
extends GameplayItem
class_name GameplayEquip

## 装备类型配置
@export var equip_type: EquipType = null

## 装备基础属性
@export var base_stats: Dictionary = {}
```

#### 3.2 实例类（运行时状态）

**ItemInstance**（运行时实例）：
```gdscript
# ItemInstance.gd
extends RefCounted
class_name ItemInstance

## 关联的配置资源
var item_config: GameplayItem

## 运行时状态
var quantity: int = 1
var current_durability: float = 100.0  # 耐久度（可选）
var instance_id: String = ""  # 实例唯一ID

## 动态属性（可能被修改的属性）
var modified_attributes: Dictionary = {}

func _init(config: GameplayItem, qty: int = 1) -> void:
    item_config = config
    quantity = qty
    instance_id = _generate_instance_id()
```

**EquipInstance**（装备实例）：
```gdscript
# EquipInstance.gd
extends ItemInstance
class_name EquipInstance

## 装备的强化等级、附魔等
var enhancement_level: int = 0
var enchantments: Array[Enchantment] = []
```

---

### 四、管理器单例系统

#### 4.1 ItemManager 单例

创建 `ItemManager` 作为 AutoLoad 单例，负责：
- 管理所有物品配置资源的注册和查找
- 通过 ID 创建物品/装备实例
- 提供物品配置的查询接口

```gdscript
# ItemManager.gd
extends Node
class_name ItemManager

## 物品配置资源字典（item_id -> GameplayItem）
var item_configs: Dictionary[StringName, GameplayItem] = {}

## 装备类型配置字典（type_id -> EquipType）
var equip_types: Dictionary[StringName, EquipType] = {}

## 初始化：加载所有配置资源
func _ready() -> void:
    _load_item_configs()
    _load_equip_types()

## 通过 ID 创建物品实例
func create_item_instance(item_id: StringName, quantity: int = 1) -> ItemInstance:
    var config = item_configs.get(item_id)
    if not config:
        push_error("ItemManager: 未找到物品配置: " + str(item_id))
        return null
    return ItemInstance.new(config, quantity)

## 通过 ID 创建装备实例
func create_equip_instance(equip_id: StringName) -> EquipInstance:
    var config = item_configs.get(equip_id)
    if not config or not config is GameplayEquip:
        push_error("ItemManager: 未找到装备配置: " + str(equip_id))
        return null
    return EquipInstance.new(config, 1)

## 获取物品配置
func get_item_config(item_id: StringName) -> GameplayItem:
    return item_configs.get(item_id)

## 获取装备类型配置
func get_equip_type(type_id: StringName) -> EquipType:
    return equip_types.get(type_id)
```

#### 4.2 配置资源加载策略

支持两种加载方式：
1. **自动扫描**：扫描指定目录下的所有 `.tres` 资源
2. **手动注册**：通过 `register_item_config()` 手动注册

---

## 🏗️ 架构重构

### 一、组件拆分

#### 1.1 InventoryComponent（基础物品管理）

**职责**：
- 物品存储（数组管理）
- 物品添加/删除
- 物品查找
- 堆叠管理

**接口**：
```gdscript
# InventoryComponent.gd
extends Node
class_name InventoryComponent

## 物品槽位数组
@export var items: Array[ItemInstance] = []

## 最大槽位数
@export var max_slot_count: int = 20

## 信号
signal item_changed
signal item_added(item: ItemInstance, slot_index: int)
signal item_removed(slot_index: int)
signal item_updated(slot_index: int)

## 添加物品
func add_item(item: ItemInstance) -> bool:
    # 尝试堆叠
    # 查找空槽位
    # 添加物品
    pass

## 移除物品
func remove_item(slot_index: int) -> void:
    pass

## 获取物品
func get_item(slot_index: int) -> ItemInstance:
    return items[slot_index] if slot_index < items.size() else null
```

#### 1.2 EquipmentComponent（装备管理）

**职责**：
- 装备槽位管理
- 装备/卸载逻辑
- 装备属性计算

**接口**：
```gdscript
# EquipmentComponent.gd
extends Node
class_name EquipmentComponent

## 装备槽位配置
@export var equip_slots: Dictionary[StringName, EquipSlotConfig] = {}

## 当前装备实例（slot_name -> EquipInstance）
var equipped_items: Dictionary[StringName, EquipInstance] = {}

## 信号
signal equip_changed(slot_name: StringName, equip: EquipInstance)
signal stats_changed

## 装备物品
func equip_item(equip: EquipInstance, slot_name: StringName = "") -> bool:
    pass

## 卸载装备
func unequip_item(slot_name: StringName) -> bool:
    pass

## 获取总属性（所有装备属性之和）
func get_total_stats() -> Dictionary:
    pass
```

#### 1.3 服务类拆分

**InventorySorter**（排序策略）：
```gdscript
# InventorySorter.gd
extends RefCounted
class_name InventorySorter

## 排序策略接口
func sort(items: Array[ItemInstance]) -> Array[ItemInstance]:
    pass
```

**ItemMerger**（合并服务）：
```gdscript
# ItemMerger.gd
extends RefCounted
class_name ItemMerger

## 合并相同物品
func merge_items(items: Array[ItemInstance]) -> Array[ItemInstance]:
    pass
```

---

### 二、策略模式：物品使用

#### 2.1 ItemUseStrategy 基类

```gdscript
# ItemUseStrategy.gd
extends RefCounted
class_name ItemUseStrategy

## 使用物品（抽象方法）
func use_item(item: ItemInstance, user: Node) -> bool:
    push_error("ItemUseStrategy.use_item() 必须在子类中实现")
    return false
```

#### 2.2 具体策略实现

**EquipUseStrategy**：
```gdscript
# EquipUseStrategy.gd
extends ItemUseStrategy
class_name EquipUseStrategy

func use_item(item: ItemInstance, user: Node) -> bool:
    if not item.item_config is GameplayEquip:
        return false
    var equipment = user.get_node_or_null("EquipmentComponent")
    if not equipment:
        return false
    return equipment.equip_item(item as EquipInstance)
```

**ConsumableUseStrategy**：
```gdscript
# ConsumableUseStrategy.gd
extends ItemUseStrategy
class_name ConsumableUseStrategy

func use_item(item: ItemInstance, user: Node) -> bool:
    # 消耗品使用逻辑
    # 恢复生命值、魔法值等
    pass
```

---

### 三、工厂模式：物品创建

#### 3.1 ItemFactory

```gdscript
# ItemFactory.gd
extends RefCounted
class_name ItemFactory

## 通过 ID 创建物品实例
static func create_item(item_id: StringName, quantity: int = 1) -> ItemInstance:
    return ItemManager.create_item_instance(item_id, quantity)

## 通过配置资源创建实例
static func create_item_from_config(config: GameplayItem, quantity: int = 1) -> ItemInstance:
    if config is GameplayEquip:
        return EquipInstance.new(config, quantity)
    return ItemInstance.new(config, quantity)
```

---

## 📁 文件结构重组

```
addons/simple_inventory/
├── scripts/
│   ├── core/
│   │   ├── components/
│   │   │   ├── InventoryComponent.gd          # 物品管理组件
│   │   │   ├── InventoryComponent.gd.uid
│   │   │   ├── EquipmentComponent.gd          # 装备管理组件
│   │   │   └── EquipmentComponent.gd.uid
│   │   │
│   │   ├── data/
│   │   │   ├── GameplayItem.gd                # 物品配置资源
│   │   │   ├── GameplayItem.gd.uid
│   │   │   ├── GameplayEquip.gd               # 装备配置资源
│   │   │   ├── GameplayEquip.gd.uid
│   │   │   ├── EquipType.gd                   # 装备类型资源
│   │   │   ├── EquipType.gd.uid
│   │   │   ├── EquipSlotConfig.gd             # 装备槽配置资源
│   │   │   ├── EquipSlotConfig.gd.uid
│   │   │   ├── ItemInstance.gd               # 物品实例（运行时）
│   │   │   ├── ItemInstance.gd.uid
│   │   │   ├── EquipInstance.gd               # 装备实例（运行时）
│   │   │   └── EquipInstance.gd.uid
│   │   │
│   │   ├── managers/
│   │   │   ├── ItemManager.gd                 # 物品管理器单例
│   │   │   └── ItemManager.gd.uid
│   │   │
│   │   ├── strategies/
│   │   │   ├── ItemUseStrategy.gd             # 物品使用策略基类
│   │   │   ├── ItemUseStrategy.gd.uid
│   │   │   ├── EquipUseStrategy.gd
│   │   │   ├── EquipUseStrategy.gd.uid
│   │   │   ├── ConsumableUseStrategy.gd
│   │   │   └── ConsumableUseStrategy.gd.uid
│   │   │
│   │   ├── services/
│   │   │   ├── ItemFactory.gd                  # 物品工厂
│   │   │   ├── ItemFactory.gd.uid
│   │   │   ├── InventorySorter.gd             # 排序服务
│   │   │   ├── InventorySorter.gd.uid
│   │   │   ├── ItemMerger.gd                   # 合并服务
│   │   │   └── ItemMerger.gd.uid
│   │   │
│   │   └── commands/
│   │       ├── CommandProcessor.gd             # 命令处理器
│   │       └── CommandProcessor.gd.uid
│   │
│   └── widgets/
│       ├── InventoryWidget.gd                 # 背包UI
│       ├── InventoryWidget.gd.uid
│       ├── inventory.tscn
│       ├── ItemSlot.gd                        # 物品槽
│       ├── ItemSlot.gd.uid
│       ├── item_slot.tscn
│       ├── EquipSlot.gd                       # 装备槽
│       ├── EquipSlot.gd.uid
│       ├── equip_slot.tscn
│       ├── ItemTile.gd                        # 物品显示
│       ├── ItemTile.gd.uid
│       ├── item_tile.tscn
│       ├── ItemTip.gd                         # 物品提示
│       ├── ItemTip.gd.uid
│       └── item_tip.tscn
│
├── plugin.cfg
├── plugin.gd
├── README.md
├── README_zh.md
└── REFACTORING_PLAN.md                        # 本文档
```

---

## 🔧 代码质量改进

### 一、类型注解完善

所有函数、变量、返回值必须显式声明类型：

```gdscript
# ✅ 正确
func add_item(item: ItemInstance) -> bool:
    var index: int = get_empty_index()
    return index != -1

# ❌ 错误
func add_item(item):
    var index = get_empty_index()
    return index != -1
```

### 二、文档注释规范

使用 `##` 进行文档注释：

```gdscript
## 添加物品到背包
## 
## 参数:
##   item: 要添加的物品实例
## 
## 返回:
##   true 如果成功添加，false 如果背包已满
func add_item(item: ItemInstance) -> bool:
    pass
```

### 三、常量提取

消除魔法数字和硬编码字符串：

```gdscript
# Constants.gd
class_name InventoryConstants

const DEFAULT_MAX_SLOTS: int = 20
const ITEM_CONFIG_PATH: String = "res://src/items/"
const EQUIP_TYPE_CONFIG_PATH: String = "res://src/equip_types/"
```

### 四、错误处理

添加完善的边界检查和错误提示：

```gdscript
func get_item(slot_index: int) -> ItemInstance:
    if slot_index < 0 or slot_index >= items.size():
        push_error("InventoryComponent: 无效的槽位索引: " + str(slot_index))
        return null
    return items[slot_index]
```

---

## 🔄 向后兼容性

### 一、别名支持

保持 `C_Inventory` 作为 `InventoryComponent` 的别名：

```gdscript
# InventoryComponent.gd
extends Node
class_name InventoryComponent

# 向后兼容别名
class_name C_Inventory = InventoryComponent
```

### 二、迁移指南

提供迁移脚本和文档，帮助现有项目平滑升级。

---

## 📊 重构优先级

### 🔴 高优先级（第一阶段）

1. **命名规范调整**
   - [ ] `Item` → `GameplayItem`
   - [ ] `Equip` → `GameplayEquip`
   - [ ] `C_Inventory` → `InventoryComponent`（保留别名）

2. **装备类型系统重构**
   - [ ] 创建 `EquipType` Resource 类
   - [ ] 移除枚举，改用 Resource
   - [ ] 更新所有相关引用

3. **配置与实例分离**
   - [ ] 创建 `ItemInstance` 类
   - [ ] 创建 `EquipInstance` 类
   - [ ] 重构 `GameplayItem` 和 `GameplayEquip` 为纯配置资源

4. **ItemManager 单例**
   - [ ] 创建 `ItemManager` 单例
   - [ ] 实现配置资源加载
   - [ ] 实现通过 ID 创建实例的接口

### 🟡 中优先级（第二阶段）

5. **组件拆分**
   - [ ] 拆分 `InventoryComponent`
   - [ ] 创建 `EquipmentComponent`
   - [ ] 重构现有代码使用新组件

6. **策略模式实现**
   - [ ] 创建 `ItemUseStrategy` 基类
   - [ ] 实现具体策略类
   - [ ] 重构物品使用逻辑

7. **服务类拆分**
   - [ ] 创建 `InventorySorter`
   - [ ] 创建 `ItemMerger`
   - [ ] 创建 `ItemFactory`

### 🟢 低优先级（第三阶段）

8. **代码质量提升**
   - [ ] 完善类型注解
   - [ ] 添加文档注释
   - [ ] 提取常量
   - [ ] 完善错误处理

9. **命令系统重构**
   - [ ] 提取 `CommandProcessor`
   - [ ] 支持命令注册和扩展

10. **性能优化**
    - [ ] 对象池（如需要）
    - [ ] 缓存优化
    - [ ] 信号优化

---

## 📝 实施步骤

### 阶段一：基础重构（1-2周）

1. 创建新的资源类和实例类
2. 实现 ItemManager 单例
3. 重构装备类型系统
4. 更新现有代码使用新结构

### 阶段二：架构优化（2-3周）

1. 拆分组件
2. 实现策略模式
3. 创建服务类
4. 重构 UI 层适配新架构

### 阶段三：质量提升（1周）

1. 完善文档和注释
2. 代码审查和优化
3. 测试和修复
4. 更新使用文档

---

## 🧪 测试计划

1. **单元测试**：核心组件和服务的单元测试
2. **集成测试**：组件间协作测试
3. **回归测试**：确保现有功能不受影响
4. **性能测试**：大量物品场景下的性能测试

---

## 📚 相关文档

- [API 文档](./API.md)（待创建）
- [迁移指南](./MIGRATION_GUIDE.md)（待创建）
- [使用示例](./EXAMPLES.md)（待创建）

---

## 🔄 更新日志

- **2024-XX-XX**：创建重构计划文档
- 后续更新将记录在此处

---

**注意**：本文档将随着重构进展持续更新。如有新的想法或需求，请及时补充。

