@tool
extends ItemSlot
class_name EquipSlot

const EQUIP_SLOT_TEXTURE : Array[Texture2D] = [
	preload("res://assets/textures/equip_slot/chest_slot.tres"),
	preload("res://assets/textures/equip_slot/feet_slot.tres"),
	preload("res://assets/textures/equip_slot/head_slot.tres"),
	preload("res://assets/textures/equip_slot/legs_slot.tres"),
	preload("res://assets/textures/equip_slot/necklace_slot.tres"),
	preload("res://assets/textures/equip_slot/ring_slot.tres"),
	preload("res://assets/textures/equip_slot/weapon_slot.tres"),
]

@onready var tr_slot: TextureRect = $MarginContainer/tr_slot
@export var equip_slot_name : StringName = ""
@export var equip_type : Equip.EQUIP_TYPE = Equip.EQUIP_TYPE.CHEST :
	set(value):
		equip_type = value
		if tr_slot:
			_display_equip_slot()

func _ready() -> void:
	_display_equip_slot()
	super()

func _display_equip_slot() -> void:
	var slot_index : int = equip_type
	tr_slot.texture = EQUIP_SLOT_TEXTURE[slot_index]

func _item_setter(value : Item) -> void:
	tr_slot.visible = value == null
	super(value)
