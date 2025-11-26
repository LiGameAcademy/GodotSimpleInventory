# 重构步骤文档

## 📋 概述

本文档提供详细的重构实施步骤，按照优先级和依赖关系组织，确保重构过程有序进行。每个步骤都包含具体的操作说明、代码示例和验证方法。

**重要提示**：
- 在开始重构前，请确保已创建代码备份或使用版本控制
- 建议在独立分支进行重构，完成测试后再合并
- 每个阶段完成后进行测试，确保功能正常

---

## 🎯 重构阶段概览

### 阶段一：基础重构（高优先级）
1. 创建新的资源类和实例类
2. 实现 ItemManager 单例
3. 重构装备类型系统
4. 更新现有代码使用新结构

### 阶段二：架构优化（中优先级）
5. 拆分组件（InventoryComponent 和 EquipmentComponent）
6. 实现策略模式（物品使用）
7. 创建服务类（排序、合并、工厂）

### 阶段三：质量提升（低优先级）
8. 完善类型注解和文档
9. 提取常量和错误处理
10. 性能优化和测试

---

## 📝 详细步骤

### 阶段一：基础重构

#### 步骤 1.1：创建新的资源类结构

**目标**：创建 `GameplayItem` 和 `GameplayEquip` 资源类，为配置与实例分离做准备。

**操作步骤**：

1. **创建目录结构**
   ```
   addons/simple_inventory/scripts/core/data/
   ```

2. **创建 `GameplayItem.gd`**
   ```gdscript
   # scripts/core/data/GameplayItem.gd
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
   
    # 临时保留旧枚举，后续重构
   enum ITEM_TYPE {
       NONE,
       CONSUMABLE,  ## 消耗品
       EQUIPMENT,   ## 装备
       MATERIAL,    ## 材料
   }
   ```

3. **创建 `GameplayEquip.gd`**
   ```gdscript
   # scripts/core/data/GameplayEquip.gd
   extends GameplayItem
   class_name GameplayEquip
   
   ## 装备类型配置（暂时保留枚举，后续改为 Resource）
   @export var equip_type: EQUIP_TYPE = EQUIP_TYPE.CHEST
   
   ## 装备基础属性
   @export var base_stats: Dictionary = {}
   
   # 临时保留旧枚举，后续重构
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

**验证方法**：
- [ ] 在编辑器中可以创建 `GameplayItem` 和 `GameplayEquip` 资源
- [ ] 类名可以正常识别和使用
- [ ] 所有导出属性可以在编辑器中配置

**注意事项**：
- 暂时保留旧的 `Item` 和 `Equip` 类，确保向后兼容
- 新类使用新的命名规范，但功能暂时与旧类保持一致

---

#### 步骤 1.2：创建实例类

**目标**：创建 `ItemInstance` 和 `EquipInstance` 类，用于存储运行时状态。

**操作步骤**：

1. **创建 `ItemInstance.gd`**
   ```gdscript
   # scripts/core/data/ItemInstance.gd
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
       if not config:
           push_error("ItemInstance: 配置资源不能为空")
           return
       item_config = config
       quantity = qty
       instance_id = _generate_instance_id()
   
   ## 生成实例唯一ID
   func _generate_instance_id() -> String:
       return str(Time.get_ticks_msec()) + "_" + str(randi())
   
   ## 获取物品名称（从配置读取）
   func get_name() -> String:
       return item_config.name if item_config else ""
   
   ## 获取物品图标（从配置读取）
   func get_icon() -> Texture2D:
       return item_config.icon if item_config else null
   
   ## 是否达到堆叠上限
   func is_stack_maxed() -> bool:
       if not item_config:
           return true
       return quantity >= item_config.max_stack
   
   ## 能否与另一个物品合并
   func can_merge_with(other: ItemInstance) -> bool:
       if not item_config or not other or not other.item_config:
           return false
       return item_config.item_id == other.item_config.item_id
   
   ## 合并物品
   func merge(other: ItemInstance) -> bool:
       if not can_merge_with(other) or is_stack_maxed():
           return false
       
       var total_quantity: int = quantity + other.quantity
       var max_stack: int = item_config.max_stack
       
       quantity = min(total_quantity, max_stack)
       other.quantity = max(0, total_quantity - max_stack)
       
       return true
   ```

2. **创建 `EquipInstance.gd`**
   ```gdscript
   # scripts/core/data/EquipInstance.gd
   extends ItemInstance
   class_name EquipInstance
   
   ## 装备的强化等级
   var enhancement_level: int = 0
   
   ## 附魔列表（可选，后续扩展）
   var enchantments: Array = []
   
   func _init(config: GameplayEquip, qty: int = 1) -> void:
       if not config or not config is GameplayEquip:
           push_error("EquipInstance: 配置必须是 GameplayEquip 类型")
           return
       super._init(config, qty)
   
   ## 获取装备类型
   func get_equip_type() -> GameplayEquip.EQUIP_TYPE:
       if not item_config or not item_config is GameplayEquip:
           return GameplayEquip.EQUIP_TYPE.CHEST
       return (item_config as GameplayEquip).equip_type
   ```

**验证方法**：
- [ ] 可以通过配置资源创建实例
- [ ] 实例可以正确读取配置属性
- [ ] 合并功能正常工作
- [ ] 堆叠上限检查正确

---

#### 步骤 1.3：创建 ItemManager 单例

**目标**：创建物品管理器单例，负责配置资源的管理和实例创建。

**操作步骤**：

1. **创建目录**
   ```
   addons/simple_inventory/scripts/core/managers/
   ```

2. **创建 `ItemManager.gd`**
   ```gdscript
   # scripts/core/managers/ItemManager.gd
   extends Node
   class_name ItemManager
   
   ## 物品配置资源字典（item_id -> GameplayItem）
   var item_configs: Dictionary[StringName, GameplayItem] = {}
   
   ## 装备类型配置字典（暂时为空，后续扩展）
   var equip_types: Dictionary[StringName, Resource] = {}
   
   ## 配置资源路径
   const ITEM_CONFIG_PATH: String = "res://addons/simple_inventory/assets/textures/items/"
   const EQUIP_TYPE_CONFIG_PATH: String = "res://addons/simple_inventory/assets/textures/equip_slot/"
   
   func _ready() -> void:
       # 暂时不自动加载，后续实现
       # _load_item_configs()
       # _load_equip_types()
       pass
   
   ## 注册物品配置
   func register_item_config(item: GameplayItem) -> void:
       if not item or item.item_id.is_empty():
           push_error("ItemManager: 物品配置无效或缺少 item_id")
           return
       item_configs[item.item_id] = item
   
   ## 通过 ID 创建物品实例
   func create_item_instance(item_id: StringName, quantity: int = 1) -> ItemInstance:
       var config: GameplayItem = item_configs.get(item_id)
       if not config:
           push_error("ItemManager: 未找到物品配置: " + str(item_id))
           return null
       return ItemInstance.new(config, quantity)
   
   ## 通过 ID 创建装备实例
   func create_equip_instance(equip_id: StringName) -> EquipInstance:
       var config: GameplayItem = item_configs.get(equip_id)
       if not config or not config is GameplayEquip:
           push_error("ItemManager: 未找到装备配置: " + str(equip_id))
           return null
       return EquipInstance.new(config as GameplayEquip, 1)
   
   ## 获取物品配置
   func get_item_config(item_id: StringName) -> GameplayItem:
       return item_configs.get(item_id)
   ```

3. **配置 AutoLoad**
   - 在项目设置中添加 `ItemManager` 为 AutoLoad 单例
   - 路径：`res://addons/simple_inventory/scripts/core/managers/ItemManager.gd`

**验证方法**：
- [ ] ItemManager 在游戏启动时自动加载
- [ ] 可以注册和查找物品配置
- [ ] 可以通过 ID 创建物品和装备实例

---

#### 步骤 1.4：创建 EquipType 和 ItemType Resource 类

**目标**：将装备类型从枚举改为 Resource，支持运行时配置。

**操作步骤**：

1. **创建 `EquipType.gd`**
   ```gdscript
   # scripts/core/data/EquipType.gd
   extends Resource
   class_name EquipType
   
   ## 装备类型唯一标识符
   @export var type_id: StringName = ""
   
   ## 显示名称
   @export var display_name: String = ""
   
   ## 图标（可选）
   @export var icon: Texture2D = null
   
   ## 槽位纹理（可选）
   @export var slot_texture: Texture2D = null
   
   ## 是否允许多个（如戒指）
   @export var allow_multiple: bool = false
   
   ## 排序优先级（用于UI显示）
   @export var sort_order: int = 0
   ```

2. **创建 `EquipSlotConfig.gd`**
   ```gdscript
   # scripts/core/data/EquipSlotConfig.gd
   extends Resource
   class_name EquipSlotConfig
   
   ## 槽位名称
   @export var slot_name: StringName = ""
   
   ## 装备类型
   @export var equip_type: EquipType = null
   
   ## 是否允许多个装备（如戒指槽位）
   @export var allow_multiple: bool = false
   ```

**验证方法**：
- [ ] 可以在编辑器中创建 EquipType 资源
- [ ] 可以在编辑器中创建 EquipSlotConfig 资源
- [ ] 资源属性可以正常配置和保存

---

#### 步骤 1.5：更新 GameplayEquip 使用 EquipType

**目标**：将 `GameplayEquip` 中的枚举改为使用 `EquipType` Resource。

**操作步骤**：

1. **更新 `GameplayEquip.gd`**
   ```gdscript
   # scripts/core/data/GameplayEquip.gd
   extends GameplayItem
   class_name GameplayEquip
   
   ## 装备类型配置（改为使用 EquipType Resource）
   @export var equip_type: EquipType = null
   
   ## 装备基础属性
   @export var base_stats: Dictionary = {}
   
   # 保留旧枚举作为向后兼容（标记为废弃）
   # @deprecated 使用 EquipType Resource 代替
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

2. **更新 `EquipInstance.gd`**
   ```gdscript
   # scripts/core/data/EquipInstance.gd
   extends ItemInstance
   class_name EquipInstance
   
   var enhancement_level: int = 0
   var enchantments: Array = []
   
   func _init(config: GameplayEquip, qty: int = 1) -> void:
       if not config or not config is GameplayEquip:
           push_error("EquipInstance: 配置必须是 GameplayEquip 类型")
           return
       super._init(config, qty)
   
   ## 获取装备类型（返回 EquipType Resource）
   func get_equip_type() -> EquipType:
       if not item_config or not item_config is GameplayEquip:
           return null
       return (item_config as GameplayEquip).equip_type
   ```

**验证方法**：
- [ ] GameplayEquip 可以使用 EquipType Resource
- [ ] EquipInstance 可以正确获取装备类型
- [ ] 旧代码仍能正常工作（向后兼容）

#### 步骤 1.6：迁移现有资源文件

**目标**：将现有的 `.tres` 资源文件迁移到新的类结构。

**操作步骤**：

1. **备份现有资源**
   - 复制 `assets/textures/items/` 目录下的所有 `.tres` 文件

2. **创建迁移脚本**（可选）
   ```gdscript
   # tools/migrate_resources.gd
   @tool
   extends EditorScript
   
   func _run() -> void:
       var items_dir = "res://addons/simple_inventory/assets/textures/items/"
       var dir = DirAccess.open(items_dir)
       
       if not dir:
           push_error("无法打开目录: " + items_dir)
           return
       
       dir.list_dir_begin()
       var file_name = dir.get_next()
       
       while file_name != "":
           if file_name.ends_with(".tres"):
               var path = items_dir + file_name
               var resource = load(path) as Resource
               
               if resource:
                   # 转换为新结构
                   var new_item = GameplayItem.new()
                   # 复制属性...
                   # ResourceSaver.save(new_item, path)
           
           file_name = dir.get_next()
   ```

3. **手动迁移（推荐）**
   - 在编辑器中打开每个 `.tres` 文件
   - 将资源类型从 `Item` 改为 `GameplayItem`
   - 将装备资源类型从 `Equip` 改为 `GameplayEquip`
   - 添加 `item_id` 属性（如果缺失）
   - 保存资源

**验证方法**：
- [ ] 所有资源文件可以正常加载
- [ ] 资源属性完整且正确
- [ ] 游戏中可以正常使用这些资源

---

### 阶段二：架构优化

#### 步骤 2.1：创建 InventoryComponent

**目标**：将 `C_Inventory` 重构为 `InventoryComponent`，专注于物品管理。

**操作步骤**：

1. **创建目录**
   ```
   addons/simple_inventory/scripts/core/components/
   ```

2. **创建 `InventoryComponent.gd`**
   ```gdscript
   # scripts/core/components/InventoryComponent.gd
   extends Node
   class_name InventoryComponent
   
   ## 物品槽位数组（使用 ItemInstance）
   @export var items: Array[ItemInstance] = []
   
   ## 最大槽位数
   @export var max_slot_count: int = 20
   
   ## 信号
   signal item_changed
   signal item_added(item: ItemInstance, slot_index: int)
   signal item_removed(slot_index: int)
   signal item_updated(slot_index: int)
   
   func _ready() -> void:
       items.resize(max_slot_count)
   
   ## 添加物品
   func add_item(item: ItemInstance) -> bool:
       if not item:
           return false
       
       # 尝试堆叠到现有物品
       for i in range(items.size()):
           var existing_item: ItemInstance = items[i]
           if existing_item and existing_item.can_merge_with(item):
               existing_item.merge(item)
               if item.quantity <= 0:
                   item_changed.emit()
                   item_updated.emit(i)
                   return true
       
       # 查找空槽位
       var empty_index: int = get_empty_index()
       if empty_index == -1:
           return false
       
       items[empty_index] = item
       item_changed.emit()
       item_added.emit(item, empty_index)
       return true
   
   ## 移除物品
   func remove_item(slot_index: int) -> void:
       if slot_index < 0 or slot_index >= items.size():
           push_error("InventoryComponent: 无效的槽位索引: " + str(slot_index))
           return
       
       items[slot_index] = null
       item_changed.emit()
       item_removed.emit(slot_index)
   
   ## 获取物品
   func get_item(slot_index: int) -> ItemInstance:
       if slot_index < 0 or slot_index >= items.size():
           return null
       return items[slot_index]
   
   ## 获取空的索引
   func get_empty_index() -> int:
       for index in range(items.size()):
           if items[index] == null:
               return index
       return -1
   
   ## 背包整理
   func pack_items() -> void:
       merge_similar_items()
       sort_items_by_type()
       item_changed.emit()
   
   ## 合并相同物品
   func merge_similar_items() -> void:
       var temp_items: Array[ItemInstance] = items.duplicate()
       
       for i in range(temp_items.size()):
           var item: ItemInstance = temp_items[i]
           if not item or item.is_stack_maxed():
               continue
           
           for j in range(i + 1, temp_items.size()):
               var other_item: ItemInstance = temp_items[j]
               if other_item and item.can_merge_with(other_item):
                   item.merge(other_item)
                   if other_item.quantity <= 0:
                       temp_items[j] = null
       
       # 过滤空槽位并重新填充
       var filtered_items: Array[ItemInstance] = temp_items.filter(func(i): return i != null)
       items.clear()
       items.resize(max_slot_count)
       
       for i in range(min(filtered_items.size(), max_slot_count)):
           items[i] = filtered_items[i]
   
   ## 按类型排序
   func sort_items_by_type() -> void:
       var temp_items: Array[ItemInstance] = items.filter(func(item): return item != null)
       temp_items.sort_custom(
           func(a: ItemInstance, b: ItemInstance) -> bool:
               if not a or not b or not a.item_config or not b.item_config:
                   return false
               return a.item_config.category < b.item_config.category
       )
       
       items.clear()
       items.resize(max_slot_count)
       for i in range(min(temp_items.size(), max_slot_count)):
           items[i] = temp_items[i]
   ```

3. **添加向后兼容别名**
   ```gdscript
   # 在文件末尾添加
   class_name C_Inventory = InventoryComponent
   ```

**验证方法**：
- [ ] InventoryComponent 可以正常添加、删除、获取物品
- [ ] 物品堆叠功能正常
- [ ] 背包整理功能正常
- [ ] 信号正常发射
- [ ] 旧代码使用 `C_Inventory` 仍能工作

---

#### 步骤 2.2：创建 EquipmentComponent

**目标**：将装备管理从 `C_Inventory` 中分离出来，创建独立的 `EquipmentComponent`。

**操作步骤**：

1. **创建 `EquipmentComponent.gd`**
   ```gdscript
   # scripts/core/components/EquipmentComponent.gd
   extends Node
   class_name EquipmentComponent
   
   ## 装备槽位配置（slot_name -> EquipSlotConfig）
   @export var equip_slot_configs: Dictionary[StringName, EquipSlotConfig] = {}
   
   ## 当前装备实例（slot_name -> EquipInstance）
   var equipped_items: Dictionary[StringName, EquipInstance] = {}
   
   ## 信号
   signal equip_changed(slot_name: StringName, equip: EquipInstance)
   signal stats_changed
   
   func _ready() -> void:
       # 初始化装备槽位
       _initialize_equip_slots()
   
   ## 初始化装备槽位
   func _initialize_equip_slots() -> void:
       # 从配置中创建默认槽位
       # 或从外部配置加载
       pass
   
   ## 装备物品
   func equip_item(equip: EquipInstance, slot_name: StringName = "") -> bool:
       if not equip:
           return false
       
       var equip_type: EquipType = equip.get_equip_type()
       if not equip_type:
           push_error("EquipmentComponent: 装备类型无效")
           return false
       
       # 如果指定了槽位名称，直接使用
       if not slot_name.is_empty():
           return _equip_to_slot(equip, slot_name)
       
       # 查找匹配的槽位
       var target_slot: StringName = _find_matching_slot(equip_type)
       if target_slot.is_empty():
           push_error("EquipmentComponent: 未找到匹配的装备槽位")
           return false
       
       return _equip_to_slot(equip, target_slot)
   
   ## 装备到指定槽位
   func _equip_to_slot(equip: EquipInstance, slot_name: StringName) -> bool:
       var old_equip: EquipInstance = equipped_items.get(slot_name)
       equipped_items[slot_name] = equip
       equip_changed.emit(slot_name, equip)
       stats_changed.emit()
       return true
   
   ## 查找匹配的槽位
   func _find_matching_slot(equip_type: EquipType) -> StringName:
       for slot_name in equip_slot_configs.keys():
           var config: EquipSlotConfig = equip_slot_configs[slot_name]
           if config and config.equip_type == equip_type:
               # 检查是否允许多个
               if config.allow_multiple or not equipped_items.has(slot_name):
                   return slot_name
       return ""
   
   ## 卸载装备
   func unequip_item(slot_name: StringName) -> bool:
       if not equipped_items.has(slot_name):
           return false
       
       var equip: EquipInstance = equipped_items[slot_name]
       equipped_items.erase(slot_name)
       equip_changed.emit(slot_name, null)
       stats_changed.emit()
       return true
   
   ## 获取总属性（所有装备属性之和）
   func get_total_stats() -> Dictionary:
       var total_stats: Dictionary = {}
       
       for slot_name in equipped_items.keys():
           var equip: EquipInstance = equipped_items[slot_name]
           if not equip or not equip.item_config:
               continue
           
           var equip_config: GameplayEquip = equip.item_config as GameplayEquip
           if not equip_config:
               continue
           
           # 合并属性
           for key in equip_config.base_stats.keys():
               if not total_stats.has(key):
                   total_stats[key] = 0
               total_stats[key] += equip_config.base_stats[key]
       
       return total_stats
   ```

**验证方法**：
- [ ] 可以装备和卸载装备
- [ ] 装备槽位匹配正确
- [ ] 多槽位装备（如戒指）正常工作
- [ ] 属性计算正确
- [ ] 信号正常发射

---

#### 步骤 2.3：更新 C_Inventory 使用新组件

**目标**：重构 `C_Inventory`，使其使用新的 `InventoryComponent` 和 `EquipmentComponent`。

**操作步骤**：

1. **更新 `C_Inventory.gd`**（保持向后兼容）
   ```gdscript
   # scripts/core/C_Inventory.gd
   extends Node
   class_name C_Inventory
   
   ## 内部组件引用
   @onready var inventory_component: InventoryComponent = $InventoryComponent
   @onready var equipment_component: EquipmentComponent = $EquipmentComponent
   
   ## 向后兼容：直接暴露组件接口
   var items: Array:
       get:
           return inventory_component.items if inventory_component else []
   
   var equip_slots: Dictionary:
       get:
           # 转换为旧格式
           var result: Dictionary = {}
           if equipment_component:
               for slot_name in equipment_component.equipped_items.keys():
                   var equip: EquipInstance = equipment_component.equipped_items[slot_name]
                   var equip_type = equip.get_equip_type() if equip else null
                   result[slot_name] = [equip_type, equip]
           return result
   
   ## 信号（转发组件的信号）
   signal item_changed
   signal equip_changed(equip_slot_name: StringName, equip: Equip)
   
   func _ready() -> void:
       # 确保组件存在
       if not inventory_component:
           inventory_component = InventoryComponent.new()
           inventory_component.name = "InventoryComponent"
           add_child(inventory_component)
       
       if not equipment_component:
           equipment_component = EquipmentComponent.new()
           equipment_component.name = "EquipmentComponent"
           add_child(equipment_component)
       
       # 连接信号
       inventory_component.item_changed.connect(_on_item_changed)
       equipment_component.equip_changed.connect(_on_equip_changed)
   
   func _on_item_changed() -> void:
       item_changed.emit()
   
   func _on_equip_changed(slot_name: StringName, equip: EquipInstance) -> void:
       # 转换为旧格式
       var old_equip: Equip = equip as Equip if equip else null
       equip_changed.emit(slot_name, old_equip)
   
   ## 向后兼容方法
   func add_item(item: Item) -> void:
       if not inventory_component:
           return
       # 转换为 ItemInstance（临时方案）
       var instance: ItemInstance = _convert_to_instance(item)
       if instance:
           inventory_component.add_item(instance)
   
   func remove_item(remove_item: Item) -> void:
       if not inventory_component:
           return
       # 查找并移除
       for i in range(inventory_component.items.size()):
           var instance: ItemInstance = inventory_component.items[i]
           if instance and instance.item_config == remove_item:
               inventory_component.remove_item(i)
               break
   
   func get_item(index: int) -> Item:
       if not inventory_component:
           return null
       var instance: ItemInstance = inventory_component.get_item(index)
       return instance.item_config as Item if instance else null
   
   func equip_item(equip: Equip) -> void:
       if not equipment_component:
           return
       # 转换为 EquipInstance（临时方案）
       var instance: EquipInstance = _convert_to_equip_instance(equip)
       if instance:
           equipment_component.equip_item(instance)
   
   ## 临时转换方法（后续移除）
   func _convert_to_instance(item: Item) -> ItemInstance:
       if not item:
           return null
       return ItemInstance.new(item as GameplayItem, item.quantity)
   
   func _convert_to_equip_instance(equip: Equip) -> EquipInstance:
       if not equip:
           return null
       return EquipInstance.new(equip as GameplayEquip, 1)
   ```

**验证方法**：
- [ ] 旧代码使用 `C_Inventory` 仍能正常工作
- [ ] 新代码可以使用 `InventoryComponent` 和 `EquipmentComponent`
- [ ] 信号正常转发
- [ ] 所有方法调用正常

---

#### 步骤 2.4：实现策略模式（物品使用）

**目标**：使用策略模式处理不同物品类型的使用逻辑。

**操作步骤**：

1. **创建目录**
   ```
   addons/simple_inventory/scripts/core/strategies/
   ```

2. **创建 `ItemUseStrategy.gd`**
   ```gdscript
   # scripts/core/strategies/ItemUseStrategy.gd
   extends RefCounted
   class_name ItemUseStrategy
   
   ## 使用物品（抽象方法）
   func use_item(item: ItemInstance, user: Node) -> bool:
       push_error("ItemUseStrategy.use_item() 必须在子类中实现")
       return false
   ```

3. **创建 `EquipUseStrategy.gd`**
   ```gdscript
   # scripts/core/strategies/EquipUseStrategy.gd
   extends ItemUseStrategy
   class_name EquipUseStrategy
   
   func use_item(item: ItemInstance, user: Node) -> bool:
       if not item or not item.item_config is GameplayEquip:
           return false
       
       var equipment: EquipmentComponent = user.get_node_or_null("EquipmentComponent")
       if not equipment:
           push_error("EquipUseStrategy: 用户节点缺少 EquipmentComponent")
           return false
       
       var equip_instance: EquipInstance = item as EquipInstance
       if not equip_instance:
           # 从 ItemInstance 创建 EquipInstance
           equip_instance = EquipInstance.new(item.item_config as GameplayEquip, 1)
       
       return equipment.equip_item(equip_instance)
   ```

4. **创建 `ConsumableUseStrategy.gd`**
   ```gdscript
   # scripts/core/strategies/ConsumableUseStrategy.gd
   extends ItemUseStrategy
   class_name ConsumableUseStrategy
   
   func use_item(item: ItemInstance, user: Node) -> bool:
       if not item or not item.item_config:
           return false
       
       if item.item_config.category != GameplayItem.ITEM_TYPE.CONSUMABLE:
           return false
       
       # 消耗品使用逻辑
       # 例如：恢复生命值、魔法值等
       var attributes: Dictionary = item.item_config.base_attributes
       
       # 这里需要根据实际游戏系统实现
       # 例如：user.get_node("HealthComponent").heal(attributes.get("heal", 0))
       
       # 减少数量
       item.quantity -= 1
       
       return true
   ```

5. **在 `InventoryComponent` 中添加使用物品方法**
   ```gdscript
   # 在 InventoryComponent.gd 中添加
   ## 使用物品
   func use_item(slot_index: int, user: Node) -> bool:
       var item: ItemInstance = get_item(slot_index)
       if not item or not item.item_config:
           return false
       
       var strategy: ItemUseStrategy = _get_use_strategy(item)
       if not strategy:
           return false
       
       var success: bool = strategy.use_item(item, user)
       
       # 如果使用后数量为0，移除物品
       if success and item.quantity <= 0:
           remove_item(slot_index)
       
       return success
   
   ## 获取使用策略
   func _get_use_strategy(item: ItemInstance) -> ItemUseStrategy:
       if not item or not item.item_config:
           return null
       
       match item.item_config.category:
           GameplayItem.ITEM_TYPE.EQUIPMENT:
               return EquipUseStrategy.new()
           GameplayItem.ITEM_TYPE.CONSUMABLE:
               return ConsumableUseStrategy.new()
           _:
               return null
   ```

**验证方法**：
- [ ] 装备物品可以正常使用（装备）
- [ ] 消耗品可以正常使用（消耗）
- [ ] 使用后数量正确减少
- [ ] 数量为0时自动移除

---

#### 步骤 2.5：创建服务类

**目标**：创建排序、合并、工厂等服务类，提升代码复用性。

**操作步骤**：

1. **创建目录**
   ```
   addons/simple_inventory/scripts/core/services/
   ```

2. **创建 `ItemFactory.gd`**
   ```gdscript
   # scripts/core/services/ItemFactory.gd
   extends RefCounted
   class_name ItemFactory
   
   ## 通过 ID 创建物品实例
   static func create_item(item_id: StringName, quantity: int = 1) -> ItemInstance:
       if not ItemManager:
           push_error("ItemFactory: ItemManager 未初始化")
           return null
       return ItemManager.create_item_instance(item_id, quantity)
   
   ## 通过配置资源创建实例
   static func create_item_from_config(config: GameplayItem, quantity: int = 1) -> ItemInstance:
       if not config:
           return null
       
       if config is GameplayEquip:
           return EquipInstance.new(config as GameplayEquip, quantity)
       return ItemInstance.new(config, quantity)
   ```

3. **创建 `InventorySorter.gd`**
   ```gdscript
   # scripts/core/services/InventorySorter.gd
   extends RefCounted
   class_name InventorySorter
   
   ## 按类型排序
   static func sort_by_type(items: Array[ItemInstance]) -> Array[ItemInstance]:
       var filtered: Array[ItemInstance] = items.filter(func(item): return item != null)
       filtered.sort_custom(
           func(a: ItemInstance, b: ItemInstance) -> bool:
               if not a or not b or not a.item_config or not b.item_config:
                   return false
               return a.item_config.category < b.item_config.category
       )
       return filtered
   
   ## 按名称排序
   static func sort_by_name(items: Array[ItemInstance]) -> Array[ItemInstance]:
       var filtered: Array[ItemInstance] = items.filter(func(item): return item != null)
       filtered.sort_custom(
           func(a: ItemInstance, b: ItemInstance) -> bool:
               if not a or not b or not a.item_config or not b.item_config:
                   return false
               return a.item_config.name < b.item_config.name
       )
       return filtered
   ```

4. **创建 `ItemMerger.gd`**
   ```gdscript
   # scripts/core/services/ItemMerger.gd
   extends RefCounted
   class_name ItemMerger
   
   ## 合并相同物品
   static func merge_items(items: Array[ItemInstance]) -> Array[ItemInstance]:
       var result: Array[ItemInstance] = []
       var processed: Array[ItemInstance] = []
       
       for item in items:
           if not item or item in processed:
               continue
           
           var merged: ItemInstance = item
           processed.append(merged)
           
           # 查找可以合并的物品
           for other in items:
               if other == item or other in processed:
                   continue
               
               if merged.can_merge_with(other) and not merged.is_stack_maxed():
                   merged.merge(other)
                   processed.append(other)
           
           result.append(merged)
       
       return result
   ```

**验证方法**：
- [ ] ItemFactory 可以正确创建物品和装备实例
- [ ] InventorySorter 可以正确排序物品
- [ ] ItemMerger 可以正确合并相同物品

---

### 阶段三：质量提升

#### 步骤 3.1：完善类型注解和文档

**目标**：为所有代码添加完整的类型注解和文档注释。

**操作步骤**：

1. **检查所有函数和变量**
   - 确保所有函数参数都有类型注解
   - 确保所有函数返回值都有类型注解
   - 确保所有变量都有类型注解

2. **添加文档注释**
   - 使用 `##` 为所有公共方法添加文档
   - 包含参数说明、返回值说明、使用示例

3. **使用代码检查工具**
   - 在 Godot 编辑器中启用类型检查
   - 修复所有类型错误和警告

**验证方法**：
- [ ] 所有代码通过类型检查
- [ ] 编辑器中可以查看完整的文档注释
- [ ] 没有类型相关的警告或错误

---

#### 步骤 3.2：提取常量和错误处理

**目标**：消除魔法数字和硬编码字符串，完善错误处理。

**操作步骤**：

1. **创建 `Constants.gd`**
   ```gdscript
   # scripts/core/Constants.gd
   class_name InventoryConstants
   
   ## 默认最大槽位数
   const DEFAULT_MAX_SLOTS: int = 20
   
   ## 物品配置路径
   const ITEM_CONFIG_PATH: String = "res://addons/simple_inventory/assets/textures/items/"
   
   ## 装备类型配置路径
   const EQUIP_TYPE_CONFIG_PATH: String = "res://addons/simple_inventory/assets/textures/equip_slot/"
   ```

2. **更新所有类使用常量**
   - 替换所有硬编码的数字和字符串
   - 使用 `InventoryConstants` 中的常量

3. **完善错误处理**
   - 添加边界检查
   - 添加错误提示信息
   - 使用 `push_error()` 和 `push_warning()` 记录错误

**验证方法**：
- [ ] 没有硬编码的数字和字符串
- [ ] 所有边界情况都有错误处理
- [ ] 错误信息清晰明确

---

#### 步骤 3.3：更新 UI 组件

**目标**：更新 UI 组件以使用新的组件架构。

**操作步骤**：

1. **更新 `InventoryWidget.gd`**
   - 修改为使用 `InventoryComponent` 和 `EquipmentComponent`
   - 更新信号连接
   - 更新物品显示逻辑

2. **更新 `ItemSlot.gd`**
   - 修改为使用 `ItemInstance`
   - 更新显示逻辑

3. **测试 UI 功能**
   - 测试物品显示
   - 测试装备显示
   - 测试交互功能

**验证方法**：
- [ ] UI 可以正常显示物品和装备
- [ ] 所有交互功能正常
- [ ] 信号连接正确
- [ ] 没有 UI 相关的错误

---

## ✅ 检查清单

### 阶段一检查清单

- [ ] 所有新的资源类和实例类已创建
- [ ] ItemManager 单例已配置并正常工作
- [ ] EquipType Resource 类已创建
- [ ] 向后兼容别名已添加
- [ ] 现有资源文件已迁移
- [ ] 所有功能测试通过

### 阶段二检查清单

- [ ] InventoryComponent 已创建并测试
- [ ] EquipmentComponent 已创建并测试
- [ ] C_Inventory 已更新并保持向后兼容
- [ ] 策略模式已实现
- [ ] 服务类已创建
- [ ] 所有功能测试通过

### 阶段三检查清单

- [ ] 所有类型注解已完善
- [ ] 所有文档注释已添加
- [ ] 常量已提取
- [ ] 错误处理已完善
- [ ] UI 组件已更新
- [ ] 性能测试通过
- [ ] 回归测试通过

---

## 🧪 测试指南

### 单元测试

为每个核心类创建单元测试：

```gdscript
# test/ItemInstanceTest.gd
extends GutTest

func test_item_instance_creation():
    var config = GameplayItem.new()
    config.item_id = "test_item"
    config.name = "Test Item"
    
    var instance = ItemInstance.new(config, 5)
    assert_not_null(instance)
    assert_eq(instance.quantity, 5)
    assert_eq(instance.get_name(), "Test Item")
```

### 集成测试

测试组件间的协作：

```gdscript
# test/InventoryIntegrationTest.gd
extends GutTest

func test_inventory_and_equipment_integration():
    var inventory = InventoryComponent.new()
    var equipment = EquipmentComponent.new()
    
    # 测试添加物品和装备的逻辑
    # ...
```

### 回归测试

确保现有功能不受影响：

- [ ] 物品添加/删除功能正常
- [ ] 装备功能正常
- [ ] UI 显示正常
- [ ] 信号发射正常
- [ ] 资源加载正常

---

## 🔄 回滚方案

如果重构过程中出现问题，可以按以下步骤回滚：

1. **使用版本控制**
   - 如果使用 Git，可以回退到重构前的提交
   - 如果使用其他版本控制，恢复备份

2. **逐步回滚**
   - 如果只是某个步骤出现问题，可以只回滚该步骤
   - 保留已完成的工作

3. **保留向后兼容**
   - 确保旧代码仍能工作
   - 新代码和旧代码可以共存

---

## 📚 相关文档

- [重构计划文档](./REFACTORING_PLAN.md) - 了解整体重构计划
- [API 文档](./API.md)（待创建）- 查看 API 参考
- [迁移指南](./MIGRATION_GUIDE.md)（待创建）- 了解如何迁移现有项目

---

## 🔄 更新日志

- **2025-11-26**：创建重构步骤文档
- 后续更新将记录在此处

---

**注意**：本文档将随着重构进展持续更新。如有问题或建议，请及时反馈。
