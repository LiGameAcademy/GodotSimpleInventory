extends Control
class_name InventoryWidgetNew

## 背包面板 Widget（对应 InventoryComponent）
## 实现逻辑表现分离：逻辑层负责数据计算，表现层负责渲染显示

#region ========== UI 节点引用 ==========

## 分解按钮
@onready var btn_decompose: Button = %ButtonDecompose
## 整理按钮
@onready var btn_pack: Button = %ButtonPack
## 背包物品网格
@onready var grid_container: GridContainer = %GridContainer
## 筛选道具的选项卡
@onready var tab_bar: TabBar = %TabBar

## 物品槽位场景资源
@export var ITEM_SLOT_SCENE: PackedScene = preload("res://addons/simple_inventory/ui/slots/item_slot.tscn")
@export var item_categories : PackedStringArray = ["consumable", "equip", "material"]

#endregion

#region ========== 逻辑层：数据管理 ==========

## 背包组件引用
var _inventory_component: InventoryComponent = null

## 当前选中的分类索引（TabBar 索引）
var _current_category_index: int = 0

## 分类映射（TabBar 索引 -> 物品类型ID，0 表示"全部"）
## 示例：{0: "", 1: "consumable", 2: "equip", 3: "material"}
var _category_type_map: Dictionary[int, StringName] = {
	0: "",  # 全部
	1: "consumable",  # 消耗品
	2: "equip",  # 装备
	3: "material",  # 材料（TODO: 需要添加 material 类型）
}

## 计算后的显示数据（槽位索引 -> GameplayItemInstance）
var _display_data: Array[GameplayItemInstance] = []

## 是否已初始化
var _is_initialized: bool = false

#endregion

#region ========== 表现层：UI 状态 ==========

## 当前选中的道具槽索引
var selected_index: int = 0:
	set(value):
		_update_selection(selected_index, false)  # 取消选中
		selected_index = value
		_update_selection(selected_index, true)   # 选中

#endregion

#region ========== 初始化 ==========

## 初始化（通过 InventoryComponent）
func initialize(component: InventoryComponent) -> void:
	if _is_initialized:
		push_warning("InventoryWidget: already initialized")
		return
	
	_inventory_component = component
	if not is_instance_valid(_inventory_component):
		push_error("InventoryWidget: _inventory_component is not valid")
		return
	
	# 连接信号
	_inventory_component.item_changed.connect(_on_item_changed)
	_inventory_component.max_slot_count_changed.connect(_on_max_slot_count_changed)
	
	# 初始化槽位连接
	_initialize_slots()
	
	# 初始化分类映射（从 TabBar 获取）
	_initialize_category_map()
	
	# 计算并更新显示
	_refresh_display()
	
	_is_initialized = true

#endregion

#region ========== 逻辑层：数据计算 ==========

## 计算显示数据（根据当前分类筛选）
func _calculate_display_data() -> Array[GameplayItemInstance]:
	if not is_instance_valid(_inventory_component):
		return []
	
	# 获取所有物品
	var all_items: Array[GameplayItemInstance] = _inventory_component.items.duplicate()
	
	# 如果选择"全部"，直接返回
	if _current_category_index == 0:
		return all_items
	
	# 获取当前分类对应的物品类型ID
	var target_type_id: StringName = _category_type_map.get(_current_category_index, "")
	if target_type_id.is_empty():
		# 如果没有映射，返回所有物品
		return all_items
	
	# 筛选物品
	var filtered_items: Array[GameplayItemInstance] = []
	for item in all_items:
		if not is_instance_valid(item) or not is_instance_valid(item.item_config):
			continue
		
		# 获取物品的类型ID
		var item_type_id: StringName = item.item_config.item_type_id
		
		# 匹配类型
		if item_type_id == target_type_id:
			filtered_items.append(item)
	
	# 确保数组大小不超过最大槽位数
	filtered_items.resize(_inventory_component.max_slot_count)
	
	return filtered_items

## 刷新显示数据（重新计算）
func _refresh_display() -> void:
	_display_data = _calculate_display_data()

#endregion

#region ========== 表现层：UI 渲染 ==========

## 更新显示（根据计算的数据渲染）
func _render_display() -> void:
	if not is_instance_valid(grid_container):
		return
	
	# 确保显示数据数组大小与槽位数量匹配
	var slot_count: int = grid_container.get_child_count()
	
	# 渲染每个槽位
	for index in range(slot_count):
		var slot: Control = grid_container.get_child(index)
		var item: GameplayItemInstance = null
		
		# 获取对应索引的物品
		if index < _display_data.size():
			item = _display_data[index]
		
		# 更新槽位显示
		_render_slot(slot, item)

## 渲染单个槽位
func _render_slot(slot: Control, item: GameplayItemInstance) -> void:
	if not is_instance_valid(slot):
		return
	
	# 尝试使用 set_item 方法
	if slot.has_method("set_item"):
		slot.set_item(item)
	# 或者直接设置 item 属性
	elif slot.has("item"):
		slot.item = item
	else:
		push_warning("InventoryWidget: slot has no set_item method or item property")

## 更新选中状态
func _update_selection(index: int, selected: bool) -> void:
	if not is_instance_valid(grid_container):
		return
	
	if index < 0 or index >= grid_container.get_child_count():
		return
	
	var slot: Control = grid_container.get_child(index)
	if not is_instance_valid(slot):
		return
	
	if selected:
		if slot.has_method("selected"):
			slot.selected()
	else:
		if slot.has_method("disselected"):
			slot.disselected()

#endregion

#region ========== 公共接口 ==========

## 显示背包
func show_inventory() -> void:
	selected_index = 0
	if tab_bar:
		tab_bar.current_tab = 0
	show()

## 隐藏背包
func hide_inventory() -> void:
	hide()

## 切换分类页签
func switch_category_tab(tab_index: int) -> void:
	_current_category_index = tab_index
	selected_index = 0
	_refresh_display()
	_render_display()

## 更新显示（公共接口，供外部调用）
func update_display() -> void:
	_refresh_display()
	_render_display()

#endregion

#region ========== 槽位管理 ==========

## 获取道具槽
func get_slot(index: int) -> Control:
	if not is_instance_valid(grid_container):
		return null
	if index < 0 or index >= grid_container.get_child_count():
		return null
	return grid_container.get_child(index)

## 初始化槽位（根据背包组件的最大格子数量动态调整）
func _initialize_slots() -> void:
	if not is_instance_valid(grid_container):
		push_error("InventoryWidget: grid_container is not valid")
		return
	
	if not is_instance_valid(_inventory_component):
		push_error("InventoryWidget: _inventory_component is not valid")
		return
	
	# 获取目标槽位数量
	var target_slot_count: int = _inventory_component.max_slot_count
	if target_slot_count <= 0:
		push_error("InventoryWidget: max_slot_count must be greater than 0")
		return
	
	# 获取当前槽位数量（只计算 ItemSlot 类型的节点，与 _connect_slot_signals 保持一致）
	var current_slots: Array[ItemSlot] = []
	for child in grid_container.get_children():
		if child is ItemSlot:
			var slot: ItemSlot = child as ItemSlot
			if is_instance_valid(slot):
				current_slots.append(slot)
	
	var current_slot_count: int = current_slots.size()
	
	# 如果槽位不够，添加新的槽位
	if current_slot_count < target_slot_count:
		var slots_to_add: int = target_slot_count - current_slot_count
		for i in range(slots_to_add):
			var new_slot: Node = ITEM_SLOT_SCENE.instantiate()
			if is_instance_valid(new_slot) and new_slot is ItemSlot:
				grid_container.add_child(new_slot)
				current_slots.append(new_slot as ItemSlot)
			else:
				push_error("InventoryWidget: failed to instantiate item_slot or invalid type")
	
	# 如果槽位太多，移除多余的槽位
	elif current_slot_count > target_slot_count:
		var slots_to_remove: int = current_slot_count - target_slot_count
		# 直接获取最后 N 个槽位进行删除，避免遍历时修改数组的问题
		for i in range(slots_to_remove):
			var index_to_remove: int = current_slots.size() - 1 - i
			if index_to_remove >= 0 and index_to_remove < current_slots.size():
				var slot_to_remove: ItemSlot = current_slots[index_to_remove]
				if is_instance_valid(slot_to_remove):
					slot_to_remove.queue_free()
	
	# 连接所有槽位的信号
	_connect_slot_signals()

## 连接槽位信号
func _connect_slot_signals() -> void:
	if not is_instance_valid(grid_container):
		return
	
	# 只遍历 ItemSlot 类型的节点，使用它们在组中的实际索引
	var slot_index: int = 0
	for child in grid_container.get_children():
		# 只处理 ItemSlot 类型的节点
		if not child is ItemSlot:
			continue
		
		var slot: ItemSlot = child as ItemSlot
		if not is_instance_valid(slot):
			continue
		
		# 断开之前的连接（如果存在）
		if slot.mouse_button_left_pressed.is_connected(_on_mouse_button_left_pressed):
			slot.mouse_button_left_pressed.disconnect(_on_mouse_button_left_pressed)
		if slot.mouse_button_right_pressed.is_connected(_on_mouse_button_right_pressed):
			slot.mouse_button_right_pressed.disconnect(_on_mouse_button_right_pressed)
		
		# 设置槽位索引（用于调试）
		slot.slot_index = slot_index
		
		# 连接新的信号（使用槽位在组中的索引，而不是在grid_container中的索引）
		slot.mouse_button_left_pressed.connect(_on_mouse_button_left_pressed.bind(slot_index))
		slot.mouse_button_right_pressed.connect(_on_mouse_button_right_pressed.bind(slot))
		slot_index += 1

## 初始化分类映射（从 ItemManager 读取物品类型配置并设置 TabBar）
func _initialize_category_map() -> void:
	if not is_instance_valid(tab_bar):
		push_error("InventoryWidget: tab_bar is not valid")
		return
	
	# 检查 ItemManager 是否可用
	if not ItemManager:
		push_error("InventoryWidget: ItemManager is not available")
		return
	
	# 重置分类映射
	_category_type_map.clear()

	tab_bar.set_tab_title(0, "全部")
	_category_type_map[0] = ""

	# 获取所有物品类型
	if item_categories.is_empty():
		push_warning("InventoryWidget: no item types found in ItemManager")
		# 设置默认的"全部"标签
		tab_bar.tab_count = 1
		return
	
	# 将物品类型转换为数组并按 sort_order 排序
	var type_list: Array[Dictionary] = []
	for type_id in item_categories:
		var item_type: GameplayItemType = ItemManager.get_item_type(type_id)
		if not is_instance_valid(item_type):
			push_warning("InventoryWidget: item type %s not found in ItemManager" % type_id)
			continue
		
		type_list.append({
			"type_id": type_id,
			"display_name": item_type.display_name,
			"sort_order": item_type.sort_order
		})
	
	# 按 sort_order 排序
	type_list.sort_custom(func(a: Dictionary, b: Dictionary): return a.sort_order < b.sort_order)
	
	# 设置 TabBar 的标签数量（"全部" + 物品类型数量）
	var tab_count: int = 1 + type_list.size()
	tab_bar.tab_count = tab_count

	# 设置其他标签（从索引1开始）
	for i in range(type_list.size()):
		var type_info: Dictionary = type_list[i]
		var tab_index: int = i + 1
		var type_id: StringName = type_info.type_id
		var display_name: String = type_info.display_name
		
		# 如果显示名称为空，使用 type_id
		if display_name.is_empty():
			display_name = str(type_id)
		
		# 设置标签标题
		tab_bar.set_tab_title(tab_index, display_name)
		
		# 更新分类映射
		_category_type_map[tab_index] = type_id

#endregion

#region ========== 用户交互处理 ==========

## 查找物品在显示数据中的索引
func _find_item_index_in_display(item: GameplayItemInstance) -> int:
	if not is_instance_valid(item):
		return -1
	
	for index in range(_display_data.size()):
		if _display_data[index] == item:
			return index
	
	return -1

## 使用物品（通过显示数据索引）
func _use_item(display_index: int) -> void:
	if not is_instance_valid(_inventory_component):
		push_error("InventoryWidget: _inventory_component is not valid")
		return
	
	# 获取显示数据中的物品
	if display_index < 0 or display_index >= _display_data.size():
		return
	
	var item: GameplayItemInstance = _display_data[display_index]
	if not is_instance_valid(item):
		return
	
	# 查找物品在原始数据中的实际索引
	var actual_index: int = _inventory_component.items.find(item)
	if actual_index < 0:
		push_warning("InventoryWidget: item not found in inventory")
		return
	
	# 使用物品（user 参数可选，如果不提供则使用组件的所有者）
	_inventory_component.use_item(actual_index)

#endregion

#region ========== 信号处理 ==========
## 鼠标左键点击
func _on_mouse_button_left_pressed(item: GameplayItemInstance, index: int) -> void:
	if not is_instance_valid(item):
		return
	print("InventoryWidget: _on_mouse_button_left_pressed: ", item.item_config.display_name, " index: ", index)
	selected_index = index

## 鼠标右键点击
func _on_mouse_button_right_pressed(item: GameplayItemInstance, _slot: ItemSlot) -> void:
	# 使用物品
	# 注意：需要使用显示数据中的索引，而不是槽位索引
	var display_index: int = _find_item_index_in_display(item)
	if display_index >= 0:
		_use_item(display_index)

func _on_item_changed() -> void:
	update_display()

## 处理最大槽位数量变化
func _on_max_slot_count_changed(old_count: int, new_count: int) -> void:
	# 重新初始化槽位（动态调整槽位数量）
	_initialize_slots()
	# 更新显示
	update_display()

func _on_tab_bar_tab_changed(tab: int) -> void:
	switch_category_tab(tab)

func _on_button_decompose_pressed() -> void:
	var slot: ItemSlot = get_slot(selected_index) as ItemSlot
	if not is_instance_valid(slot):
		return
	
	var selected_item: GameplayItemInstance = slot.get_item()
	if not is_instance_valid(selected_item):
		return
	
	# 查找物品在原始数据中的实际索引
	var actual_index: int = _inventory_component.items.find(selected_item)
	if actual_index < 0:
		push_warning("InventoryWidget: item not found in inventory")
		return
	
	# 移除物品
	if is_instance_valid(_inventory_component):
		_inventory_component.remove_item(actual_index)
	else:
		push_error("InventoryWidget: _inventory_component is not valid")

func _on_button_pack_pressed() -> void:
	if is_instance_valid(_inventory_component):
		_inventory_component.pack_items()
	else:
		push_error("InventoryWidget: _inventory_component is not valid")

#endregion
