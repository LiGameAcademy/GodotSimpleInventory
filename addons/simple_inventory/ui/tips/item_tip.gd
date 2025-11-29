extends MarginContainer

@onready var tr_icon: TextureRect = %TextureRectIcon
@onready var lab_name: Label = %LabelName
@onready var lab_count: Label = %LabelCount
@onready var lab_des: Label = %LabelDescription

func update_display(item_instance: GameplayItemInstance) -> void:
	await ready
	if not is_instance_valid(item_instance) or not is_instance_valid(item_instance.item_config):
		return
	
	var config: GameplayItem = item_instance.item_config
	tr_icon.texture = config.icon
	lab_name.text = config.display_name
	lab_count.text = "拥有" + str(item_instance.quantity) + "个"
	lab_des.text = config.description
	
