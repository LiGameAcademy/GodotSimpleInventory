extends MarginContainer

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

## 道具提示场景资源
@export var S_ITEM_TIP: PackedScene = preload("res://addons/simple_inventory/ui/tips/item_tip.tscn")

var item_res: GameplayItemInstance:
	set(value):
		if is_instance_valid(item_res):
			item_res.quantity_changed.disconnect(_on_item_quantity_changed)
		item_res = value
		if is_instance_valid(item_res):
			item_res.quantity_changed.connect(_on_item_quantity_changed)

## 更新显示
func update_display(item_instance: GameplayItemInstance) -> void:
	item_res = item_instance
	if not is_instance_valid(item_instance) or not is_instance_valid(item_instance.item_config):
		texture_rect.texture = null
		label.hide()
		return
	
	var config: GameplayItem = item_instance.item_config
	texture_rect.texture = config.icon
	if config.max_stack <= 1:
		label.hide()
	else:
		label.show()
		label.text = str(item_instance.quantity)
	# tooltip_text = config.display_name + " : " + config.description

## 道具数量变化信号处理
func _on_item_quantity_changed(value: int) -> void:
	if is_instance_valid(item_res) and is_instance_valid(item_res.item_config):
		if item_res.item_config.max_stack > 1:
			label.text = str(value)

## 创建自定义提示
func _make_custom_tooltip(_for_text: String) -> Object:
	var item_tip = S_ITEM_TIP.instantiate()
	if not is_instance_valid(item_tip):
		push_error("ItemTile: item_tip is not valid")
		return null
	if item_tip.has_method("update_display"):
		item_tip.update_display(item_res)
	else:
		push_warning("ItemTile: item_tip has no update_display method")
	return item_tip
