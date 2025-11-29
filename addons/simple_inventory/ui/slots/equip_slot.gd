@tool
extends ItemSlot
class_name EquipSlot

@onready var slot_icon: TextureRect = %SlotIcon

## 槽位ID
@export var equip_slot : GameplayEquipSlotConfig = null

func _ready() -> void:
	_display_equip_slot()
	super()

func _display_equip_slot() -> void:
	if not is_instance_valid(equip_slot):
		return
	slot_icon.texture = equip_slot.slot_texture
	# 有装备时隐藏槽图标，无装备时显示槽图标
	slot_icon.visible = not is_instance_valid(_item_res)
	item_tile.visible = is_instance_valid(_item_res)

func set_item(value : GameplayItemInstance) -> void:
	_item_res = value
	# 有装备时隐藏槽图标，无装备时显示槽图标
	slot_icon.visible = not is_instance_valid(value)
	item_tile.visible = is_instance_valid(value)
	if is_instance_valid(value):
		item_tile.update_display(value)
		item_tile.show()
	else:
		item_tile.hide()

## 获取槽位ID（用于 UI 兼容）
func get_slot_id() -> StringName:
	if not is_instance_valid(equip_slot):
		return ""
	return equip_slot.slot_id
