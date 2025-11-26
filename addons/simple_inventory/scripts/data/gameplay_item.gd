extends Resource
class_name GameplayItem

## 物品唯一标识符
@export var item_id: StringName = ""

## 物品类型ID（引用 GameplayItemType）
@export var item_type_id: StringName = ""

# 物品基础属性（配置数据）
## 物品显示名称
@export var display_name: String = "道具名称"
## 物品图标
@export var icon: Texture2D = null
## 物品描述
@export var description: String = "道具描述"
## 物品最大堆叠数量
@export var max_stack: int = 1
## 物品重量
@export var weight: float = 0.0
