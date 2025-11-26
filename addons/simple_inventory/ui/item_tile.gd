extends MarginContainer

const S_ITEM_TIP = preload("res://addons/simple_inventory/widgets/item_tip.tscn")

@export var item_res: Item:
	set(value):
		if item_res != null:
			item_res.quantity_changed.disconnect(_on_item_quantity_changed)
		item_res = value
		if item_res != null:
			item_res.quantity_changed.connect(_on_item_quantity_changed)
@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

## 更新显示
func update_display(res: Item) -> void:
	item_res = res
	texture_rect.texture = item_res.icon
	if item_res.max_stack <= 1:
		label.hide()
	else:
		label.show()
		label.text = str(item_res.quantity)
	# tooltip_text = item_res.name + " : " + item_res.description

func _on_item_quantity_changed(value: int) -> void:
	if item_res.max_stack > 1:
		label.text = str(item_res.quantity)

func _make_custom_tooltip(_for_text: String) -> Object:
	var item_tip = S_ITEM_TIP.instantiate()
	item_tip.update_display(item_res)
	return item_tip
