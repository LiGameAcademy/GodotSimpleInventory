extends Control
class_name EquipmentWidgetNew

## 装备栏面板 Widget（对应 EquipmentComponent）

## 装备槽位字典（slot_id -> EquipSlot）
var equip_slots: Dictionary[StringName, EquipSlot] = {}
## 装备组件引用
var equipment_component: EquipmentComponent = null

## 初始化（通过 EquipmentComponent）
func initialize(component: EquipmentComponent) -> void:
	equipment_component = component
	if not is_instance_valid(equipment_component):
		push_error("EquipmentWidget: equipment_component is not valid")
		return
	
	# 连接信号
	equipment_component.equip_changed.connect(_on_equip_changed)
	
	# 初始化槽位
	_initialize_slots()
	
	# 更新显示
	update_display()

## 更新显示
func update_display() -> void:
	if not is_instance_valid(equipment_component):
		return
	
	for slot_id in equip_slots.keys():
		var equip: GameplayEquipInstance = equipment_component.get_equip(slot_id)
		var slot: EquipSlot = equip_slots.get(slot_id)
		if is_instance_valid(slot):
			slot.set_item(equip)

## 显示装备栏
func show_equipment() -> void:
	self.show()

## 隐藏装备栏
func hide_equipment() -> void:
	self.hide()

## 初始化槽位
func _initialize_slots() -> void:
	equip_slots.clear()
	
	# 从场景中查找所有装备槽位
	var slots: Array = get_tree().get_nodes_in_group("equip_slot")
	
	for slot in slots:
		if not slot is EquipSlot:
			push_warning("EquipmentWidget: 槽位不是 EquipSlot，将跳过")
			continue
		if not slot.visible:
			continue
		
		var equip_slot: EquipSlot = slot as EquipSlot
		var slot_id: StringName = equip_slot.get_slot_id()
		if slot_id.is_empty():
			push_warning("EquipmentWidget: 槽位缺少 slot_id，将跳过")
			continue
		if equip_slots.has(slot_id):
			push_warning("EquipmentWidget: 槽位重复，将覆盖!")

		equip_slots[slot_id] = equip_slot
		
		# 连接信号
		equip_slot.mouse_button_left_pressed.connect(_on_mouse_button_left_pressed.bind(slot_id))
		equip_slot.mouse_button_right_pressed.connect(_on_mouse_button_right_pressed.bind(slot_id))
	
## 鼠标左键点击
func _on_mouse_button_left_pressed(_item_res: GameplayItemInstance, _slot_id: StringName) -> void:
	# 可以在这里实现选中逻辑
	pass

## 鼠标右键点击
func _on_mouse_button_right_pressed(item_res: GameplayItemInstance, slot_id: StringName) -> void:
	# 卸载装备
	if not is_instance_valid(equipment_component):
		push_error("EquipmentWidget: equipment_component is not valid")
		return
	if not is_instance_valid(item_res):
		push_error("EquipmentWidget: item_res is not valid")
		return
	var success: bool = equipment_component.unequip_item(slot_id)
	if not success:
		push_error("EquipmentWidget: unequip_item failed")
		return

## 装备变化信号处理
func _on_equip_changed(slot_id: StringName, equip: GameplayEquipInstance) -> void:
	var slot: EquipSlot = equip_slots.get(slot_id)
	if is_instance_valid(slot):
		slot.set_item(equip)
