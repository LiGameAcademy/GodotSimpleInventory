extends MarginContainer
class_name ItemSlot

@onready var color_rect: ColorRect = %ColorRect
@onready var item_tile: MarginContainer = $item_tile

var item : Item = null : set = _item_setter

signal mouse_button_left_pressed
signal mouse_button_right_pressed

func _ready() -> void:
	self.gui_input.connect(_on_gui_input)
	color_rect.visible = false

## 选中道具槽
func selected() -> void:
	color_rect.color = Color.WHITE
	color_rect.visible = true

## 取消选中道具槽
func disselected() -> void:
	#color_rect.color = Color.BLACK
	color_rect.visible = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() :
		if event.button_index == MOUSE_BUTTON_LEFT:
			mouse_button_left_pressed.emit()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_button_right_pressed.emit()

func _item_setter(value : Item) -> void:
	item = value
	if item != null:
		item_tile.update_display(item)
		item_tile.show()
	else:
		item_tile.hide()	
