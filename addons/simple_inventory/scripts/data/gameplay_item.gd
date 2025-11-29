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

@export var sort_order: int = 0

func _init(
		p_item_id: StringName = "",
		p_item_type_id: StringName = "",
		p_display_name: String = "",
		p_icon: Texture2D = null,
		p_description: String = "",
		p_max_stack: int = 1,
		p_weight: float = 0.0,
		p_sort_order: int = 0
		) -> void:
	item_id = p_item_id
	item_type_id = p_item_type_id
	display_name = p_display_name
	icon = p_icon
	description = p_description
	max_stack = p_max_stack
	weight = p_weight
	sort_order = p_sort_order