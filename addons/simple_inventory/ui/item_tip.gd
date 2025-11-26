extends MarginContainer

@onready var tr_icon: TextureRect = %tr_icon
@onready var lab_name: Label = %lab_name
@onready var lab_count: Label = %lab_count
@onready var lab_des: Label = %lab_des
@onready var lab_attribute_title: Label = %lab_attribute_title
@onready var lab_attribute: Label = %lab_attribute

func update_display(item: Item) -> void:
	await ready
	tr_icon.texture = item.icon
	lab_name.text = item.name
	lab_count.text = "拥有" + str(item.quantity) + "个"
	lab_des.text = item.description
	if item.attributes.is_empty():
		lab_attribute.hide()
		lab_attribute_title.hide()
	else:
		lab_attribute.show()
		lab_attribute_title.show()
		lab_attribute.text = ""
		for attribute in item.attributes:
			lab_attribute.text += attribute + ":" + str(item.attributes[attribute])
