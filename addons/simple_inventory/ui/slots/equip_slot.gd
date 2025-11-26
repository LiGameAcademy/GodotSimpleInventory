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
	item_tile.visible = is_instance_valid(_item_res)

func set_item(value : GameplayItemInstance) -> void:
	item_tile.visible = is_instance_valid(value)
	super(value)

## 获取槽位ID（用于 UI 兼容）
func get_slot_id() -> StringName:
	if not is_instance_valid(equip_slot):
		return ""
	return equip_slot.slot_id
