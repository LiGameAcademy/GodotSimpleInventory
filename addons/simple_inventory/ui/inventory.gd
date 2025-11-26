extends Control
class_name InventoryWidget

## 分解按钮
@onready var btn_decompose: Button = %btn_decompose
## 整合按钮
@onready var btn_pack: Button = %btn_pack
## 背包孔网格
@onready var grid_container: GridContainer = %GridContainer
## 筛选道具的选项卡
@onready var tab_bar: TabBar = %TabBar
## 退出按钮
@onready var btn_close: Button = %btn_close

var c_inventory : C_Inventory = null

## 当前选中的道具槽
var selected_index : int = 0:
	set(value):
		var slot = get_slot(selected_index)
		slot.disselected()
		selected_index = value
		slot = get_slot(selected_index)
		slot.selected()

## 当前选中的类型
var current_category: int = 0

## 背包初始化
func initialize(inventory : C_Inventory) -> void:
	c_inventory = inventory
	c_inventory.item_changed.connect(_on_item_changed)
	c_inventory.equip_changed.connect(_on_equip_changed)
	var index = 0
	for slot in get_tree().get_nodes_in_group("item_slot"):
		slot.mouse_button_left_pressed.connect(_on_mouse_button_left_pressed.bind(index))
		slot.mouse_button_right_pressed.connect(_on_mouse_button_right_pressed.bind(slot))
		if not slot.is_in_group("equip_slot"):
			slot.item = c_inventory.items[index]
			index += 1
		else:
			slot.item = c_inventory.equip_slots[slot.equip_slot_name][1]

## 开启背包
func open() -> void:
	selected_index = 0
	tab_bar.current_tab = 0
	self.show()

## 切换分类页签
func switch_category_tab(tab: int) -> void:
	selected_index = 0
	current_category = tab
	update_display()

## 获取分类的道具
func get_category_items() -> Array[Item]:
	var items = c_inventory.items.duplicate()
	if current_category == 0:
		return items
	var filter_items : Array = items.filter(
		func(item: Item):
			if item == null: return false
			return item.category == current_category
	)
	filter_items.resize(c_inventory.MAX_SLOT_COUNT)
	return filter_items

## 更新显示
func update_display() -> void:
	var items : Array[Item] = get_category_items()
	for index in items.size():
		var slot = grid_container.get_child(index)
		slot.item = items[index]

## 获取槽
func get_slot(index: int) -> Control:
	return grid_container.get_child(index)

## 鼠标左键点击
func _on_mouse_button_left_pressed(index: int) -> void:
	selected_index = index

## 鼠标右键点击
func _on_mouse_button_right_pressed(slot : ItemSlot) -> void:
	if slot.is_in_group("equip_slot"):
		c_inventory.unequip_item(slot.item)
	else:
		c_inventory.use_item(slot.item)

## 分解道具
func _on_btn_decompose_pressed() -> void:
	var slot : ItemSlot = get_slot(selected_index)
	var selected_item : Item = slot.item
	if selected_item :
		c_inventory.remove_item(selected_item)

## 整理背包
func _on_btn_pack_pressed() -> void:
	c_inventory.pack_items()

func _on_tab_bar_tab_changed(tab: int) -> void:
	switch_category_tab(tab)

func _on_btn_close_pressed() -> void:
	self.hide()

func _on_item_changed() -> void:
	update_display()

func _on_equip_changed(equip_slot_name : StringName, equip : Equip) -> void:
	var equip_slots = get_tree().get_nodes_in_group("equip_slot")
	for slot in equip_slots:
		if slot.equip_slot_name == equip_slot_name:
			slot.item = equip
