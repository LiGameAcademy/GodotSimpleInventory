extends Control
class_name EquipmentWidgetNew

## 只发现自身子树的槽位；向宿主发出卸装意图。
signal unequip_requested(slot_id: StringName)

var equip_slots: Dictionary[StringName, EquipSlot] = {}
var equipment_component: EquipmentComponent


func initialize(component: EquipmentComponent) -> void:
	if is_instance_valid(equipment_component) and equipment_component.equip_changed.is_connected(_on_equip_changed):
		equipment_component.equip_changed.disconnect(_on_equip_changed)
	for old_id: StringName in equip_slots:
		var old_slot: EquipSlot = equip_slots[old_id]
		var handler: Callable = _on_mouse_button_right_pressed.bind(old_id)
		if old_slot.mouse_button_right_pressed.is_connected(handler):
			old_slot.mouse_button_right_pressed.disconnect(handler)
	equip_slots.clear()
	equipment_component = component
	if not is_instance_valid(component):
		return
	_collect_slots(self)
	component.equip_changed.connect(_on_equip_changed)
	update_display()


func update_display() -> void:
	if not is_instance_valid(equipment_component):
		return
	for slot_id: StringName in equip_slots:
		equip_slots[slot_id].set_item(equipment_component.get_equip(slot_id))


func show_equipment() -> void:
	show()


func hide_equipment() -> void:
	hide()


func _collect_slots(node: Node) -> void:
	for child: Node in node.get_children():
		if child is EquipSlot:
			var slot: EquipSlot = child as EquipSlot
			var slot_id: StringName = slot.get_slot_id()
			if not slot_id.is_empty() and not equip_slots.has(slot_id):
				equip_slots[slot_id] = slot
				slot.mouse_button_right_pressed.connect(_on_mouse_button_right_pressed.bind(slot_id))
		_collect_slots(child)


func _on_mouse_button_right_pressed(item: GameplayItemInstance, slot_id: StringName) -> void:
	if is_instance_valid(item):
		unequip_requested.emit(slot_id)


func _on_equip_changed(slot_id: StringName, equip: GameplayEquipInstance) -> void:
	var slot: EquipSlot = equip_slots.get(slot_id, null)
	if is_instance_valid(slot):
		slot.set_item(equip)
