extends Control
class_name InventoryPanel

## 背包面板（组合 InventoryWidget 和 EquipmentWidget）

## 背包 Widget
@onready var inventory_widget: InventoryWidgetNew = %InventoryWidget
## 装备栏 Widget
@onready var equipment_widget: EquipmentWidgetNew = %EquipmentWidget
## 关闭按钮
@onready var btn_close: Button = %ButtonClose

var _inventory: InventoryComponent
var _equipment: EquipmentComponent
var _user: Node

func _ready() -> void:
	inventory_widget.item_use_requested.connect(_on_item_use_requested)
	equipment_widget.unequip_requested.connect(_on_unequip_requested)

func initialize_components(inventory: InventoryComponent, equipment: EquipmentComponent, user: Node) -> void:
	_inventory = inventory
	_equipment = equipment
	_user = user
	inventory.initialize(user, equipment)
	inventory_widget.initialize(inventory)
	equipment_widget.initialize(equipment)

## 初始化（通过 C_Inventory）
func initialize(entity: Node) -> void:
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(entity)
	var equipment_comp: EquipmentComponent = EquipmentComponent.get_equipment_component(entity)
	if is_instance_valid(inventory_comp) and is_instance_valid(equipment_comp):
		initialize_components(inventory_comp, equipment_comp, entity)

func _on_item_use_requested(slot_index: int) -> void:
	if is_instance_valid(_inventory):
		_inventory.use_item(slot_index, _user)

func _on_unequip_requested(slot_id: StringName) -> void:
	if is_instance_valid(_equipment) and is_instance_valid(_inventory):
		_equipment.unequip_item(slot_id, _inventory)

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
