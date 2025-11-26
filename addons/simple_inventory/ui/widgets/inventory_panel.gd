extends Control
class_name InventoryPanel

## 背包面板（组合 InventoryWidget 和 EquipmentWidget）

## 背包 Widget
@onready var inventory_widget: InventoryWidgetNew = %InventoryWidget
## 装备栏 Widget
@onready var equipment_widget: EquipmentWidgetNew = %EquipmentWidget
## 关闭按钮
@onready var btn_close: Button = %ButtonClose

## 初始化（通过 C_Inventory）
func initialize(entity: Node) -> void:
	var inventory_comp : InventoryComponent = InventoryComponent.get_inventory_component(entity)
	if is_instance_valid(inventory_comp):
		inventory_widget.initialize(inventory_comp)
	else:
		push_error("InventoryPanel: inventory_component is not valid")
	var equipment_comp : EquipmentComponent = EquipmentComponent.get_equipment_component(entity)
	if is_instance_valid(equipment_comp):
		equipment_widget.initialize(equipment_comp)
	else:
		push_error("InventoryPanel: equipment_component is not valid")

## 显示面板
func open() -> void:
	if is_instance_valid(inventory_widget):
		inventory_widget.show_inventory()
	if is_instance_valid(equipment_widget):
		equipment_widget.show_equipment()
	self.show()

## 隐藏面板
func close() -> void:
	if is_instance_valid(inventory_widget):
		inventory_widget.hide_inventory()
	if is_instance_valid(equipment_widget):
		equipment_widget.hide_equipment()
	self.hide()

## 关闭按钮处理
func _on_btn_close_pressed() -> void:
	close()
