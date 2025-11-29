extends GameplayItem
class_name GameplayEquip

## 装备配置

## 装备类型ID（引用 GameplayEquipType）
@export var equip_type_id: StringName = ""

func _init(
		p_item_id: StringName = "",
		p_item_type_id: StringName = "",
		p_display_name: String = "",
		p_icon: Texture2D = null,
		p_description: String = "",
		p_max_stack: int = 1,
		p_weight: float = 0.0,
		p_equip_type_id: StringName = "",
		p_sort_order: int = 0,
		) -> void:
	super(p_item_id, p_item_type_id, p_display_name, p_icon, p_description, p_max_stack, p_weight, p_sort_order)
	equip_type_id = p_equip_type_id
