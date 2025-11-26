extends MarginContainer

@onready var tr_icon: TextureRect = %tr_icon
@onready var lab_name: Label = %lab_name
@onready var lab_count: Label = %lab_count
@onready var lab_des: Label = %lab_des
@onready var lab_attribute_title: Label = %lab_attribute_title
@onready var lab_attribute: Label = %lab_attribute

func update_display(item_instance: GameplayItemInstance) -> void:
	await ready
	if not is_instance_valid(item_instance) or not is_instance_valid(item_instance.item_config):
		return
	
	var config: GameplayItem = item_instance.item_config
	tr_icon.texture = config.icon
	lab_name.text = config.display_name
	lab_count.text = "拥有" + str(item_instance.quantity) + "个"
	lab_des.text = config.description
	
	# TODO: 显示物品属性（需要根据新的架构实现属性系统）
	lab_attribute.hide()
	lab_attribute_title.hide()
	# if item.attributes.is_empty():
	# 	lab_attribute.hide()
	# 	lab_attribute_title.hide()
	# else:
	# 	lab_attribute.show()
	# 	lab_attribute_title.show()
	# 	lab_attribute.text = ""
	# 	for attribute in item.attributes:
	# 		lab_attribute.text += attribute + ":" + str(item.attributes[attribute])
