# 槽、装备类型、装备三者关系说明

## 📋 关系图

```
GameplayEquipType (装备类型定义)
    ├── type_id: "weapon" (唯一标识符)
    ├── display_name: "武器" (显示名称)
    └── allow_multiple: false (类型级别：是否支持多个)

GameplayEquipSlotConfig (装备槽位配置)
    ├── slot_id: "weapon_main" (槽位唯一标识符)
    ├── display_name: "主手武器" (槽位显示名称)
    ├── equip_type_id: "weapon" (引用装备类型ID)
    └── allow_multiple: false (槽位级别：是否允许多个装备)

GameplayEquip (装备物品)
    ├── item_id: "sword_iron" (物品唯一标识符)
    └── equip_type_id: "weapon" (引用装备类型ID)

GameplayEquipInstance (装备实例)
    └── item_config: GameplayEquip (引用装备配置)
```

## 🔗 关系说明

### 1. GameplayEquipType（装备类型）

**职责**：定义装备类型的通用属性

**关键属性**：
- `type_id`: 类型唯一标识符（如 "weapon", "ring"）
- `display_name`: 显示名称（如 "武器", "戒指"）
- `allow_multiple`: 类型级别 - 这种类型的装备是否支持多个

**作用**：
- 装备物品通过 `equip_type_id` 引用类型
- 装备槽位通过 `equip_type_id` 引用类型，确定可以装备哪些类型的装备

### 2. GameplayEquipSlotConfig（装备槽位配置）

**职责**：定义具体的装备槽位及其规则

**关键属性**：
- `slot_id`: 槽位唯一标识符（如 "weapon_main", "ring_1"）
- `display_name`: 槽位显示名称（如 "主手武器", "戒指槽1"）
- `equip_type_id`: 引用的装备类型ID（指向 GameplayEquipType）
- `allow_multiple`: 槽位级别 - 这个槽位是否允许多个装备

**作用**：
- 定义角色的装备槽位布局
- 通过 `equip_type_id` 匹配可以装备的装备类型
- 控制槽位的规则（是否允许多个等）

### 3. GameplayEquip（装备物品）

**职责**：定义装备物品的配置

**关键属性**：
- `item_id`: 物品唯一标识符
- `equip_type_id`: 引用的装备类型ID（指向 GameplayEquipType）

**作用**：
- 装备物品通过 `equip_type_id` 声明自己的类型
- 装备系统通过 `equip_type_id` 匹配到对应的槽位

### 4. GameplayEquipInstance（装备实例）

**职责**：装备的运行时实例

**关键属性**：
- `item_config`: 引用 GameplayEquip 配置
- `enhancement_level`: 强化等级等运行时状态

**作用**：
- 存储装备的运行时状态
- 通过 `item_config.equip_type_id` 获取装备类型

## 🔄 匹配流程

### 装备流程

```
1. 玩家使用装备物品
   ↓
2. 获取 GameplayEquipInstance
   ↓
3. 通过 equip.get_equip_type_resource() 获取 GameplayEquipType
   ↓
4. EquipmentComponent._find_matching_slot() 查找匹配槽位：
   - 遍历所有 equip_slot_configs
   - 比较 slot_config.equip_type_id == equip.equip_type_id
   - 检查槽位是否可用（allow_multiple 或槽位为空）
   ↓
5. 装备到匹配的槽位
```

### 槽位配置流程

```
1. 在编辑器中配置 equip_slot_configs_array
   ↓
2. EquipmentComponent._initialize_equip_slots()
   - 遍历数组
   - 以 slot_id 为键，转换为字典
   ↓
3. 运行时通过 slot_id 快速查找槽位配置
```

## 💡 设计优势

1. **类型复用**：一个装备类型可以被多个槽位引用
2. **灵活配置**：可以为不同角色配置不同的槽位布局
3. **清晰关系**：通过ID引用，关系明确
4. **易于扩展**：新增装备类型不影响现有槽位，新增槽位不影响现有类型

## 📝 命名规范

- **ID字段**：使用 `_id` 后缀，如 `slot_id`, `equip_type_id`, `item_id`
- **显示名称**：使用 `display_name`，用于UI显示
- **配置数组**：使用 `_array` 后缀，如 `equip_slot_configs_array`
- **运行时字典**：使用复数形式，如 `equip_slot_configs`, `equipped_items`

