extends MarginContainer
class_name ItemSlot

@onready var color_rect: ColorRect = %ColorRect
@onready var item_tile: MarginContainer = $ItemTile

var _item_res : GameplayItemInstance = null
## 槽位索引（用于调试）
var slot_index: int = -1

signal mouse_button_left_pressed(item_res : GameplayItemInstance)
signal mouse_button_right_pressed(item_res : GameplayItemInstance)

func _ready() -> void:
	color_rect.visible = false
	set_item(_item_res)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() :
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_button_left_pressed.emit(_item_res)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_button_right_pressed.emit(_item_res)

## 选中道具槽
func selected() -> void:
	color_rect.color = Color.WHITE
	color_rect.visible = true

## 取消选中道具槽
func disselected() -> void:
	#color_rect.color = Color.BLACK
	color_rect.visible = false

## 设置道具
func set_item(value : GameplayItemInstance) -> void:
	_item_res = value
	if is_instance_valid(_item_res):
		item_tile.update_display(_item_res)
		item_tile.show()
	else:
		item_tile.hide()

func get_item() -> GameplayItemInstance:
	return _item_res
