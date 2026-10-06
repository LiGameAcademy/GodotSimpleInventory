extends Node
class_name EquipmentComponent

## 每个 slot_id 持有一个独占实例；多个戒指用多个槽位表达。
@export var equip_slot_configs_array: Array[GameplayEquipSlotConfig] = []
var equip_slot_configs: Dictionary[StringName, GameplayEquipSlotConfig] = {}
var equipped_items: Dictionary[StringName, GameplayEquipInstance] = {}

signal equip_changed(slot_id: StringName, equip: GameplayEquipInstance)


func _ready() -> void:
	_initialize_equip_slots()


## 指定来源槽时必须仍持有该装备。失败不更改背包、装备或所有权。
func equip_item(equip: GameplayEquipInstance, slot_id: StringName = "", inventory_component: InventoryComponent = null, source_slot_index: int = -1) -> bool:
	if not is_instance_valid(equip) or not is_instance_valid(equip.item_config):
		return false
	if equip.quantity != 1:
		return false
	var equip_type: GameplayEquipType = equip.get_equip_type_resource()
	if not is_instance_valid(equip_type):
		return false
	var target: StringName = slot_id if not slot_id.is_empty() else _find_matching_slot(equip_type)
	return _equip_to_slot(equip, target, inventory_component, source_slot_index)


## 没有背包时只解除持有关系，调用方可提前 get_equip() 保留实例。
func unequip_item(slot_id: StringName, inventory_component: InventoryComponent = null) -> bool:
	var equip: GameplayEquipInstance = get_equip(slot_id)
	if not is_instance_valid(equip):
		return false
	if is_instance_valid(inventory_component) and not inventory_component.has_capacity_for(equip):
		return false
	equipped_items.erase(slot_id)
	equip.release_container(self)
	if is_instance_valid(inventory_component):
		if not inventory_component.add_item(equip):
			equipped_items[slot_id] = equip
			equip.claim_container(self)
			return false
	equip_changed.emit(slot_id, null)
	return true


func get_equip(slot_id: StringName) -> GameplayEquipInstance:
	return equipped_items.get(slot_id, null)

## 恢复快照的权威写入口；配置仍由场景提供。
func replace_contents(replacement: Dictionary[StringName, GameplayEquipInstance], notify: bool = true) -> bool:
	var seen: Array[GameplayEquipInstance] = []
	for slot_id: StringName in replacement:
		var item: GameplayEquipInstance = replacement[slot_id]
		var config: GameplayEquipSlotConfig = equip_slot_configs.get(slot_id, null)
		if not is_instance_valid(item) or not is_instance_valid(config):
			return false
		if item.quantity != 1 or item.get_equip_type_id() != config.equip_type_id:
			return false
		if seen.has(item) or (item.get_container() != null and item.get_container() != self):
			return false
		seen.append(item)
	for item: GameplayEquipInstance in equipped_items.values():
		item.release_container(self)
	equipped_items = replacement.duplicate()
	for item: GameplayEquipInstance in equipped_items.values():
		item.claim_container(self)
	if notify:
		notify_contents_changed()
	return true

func notify_contents_changed() -> void:
	for slot_id: StringName in equip_slot_configs:
		equip_changed.emit(slot_id, get_equip(slot_id))


func _initialize_equip_slots() -> void:
	equip_slot_configs.clear()
	for config: GameplayEquipSlotConfig in equip_slot_configs_array:
		if not is_instance_valid(config) or config.slot_id.is_empty():
			continue
		if equip_slot_configs.has(config.slot_id):
			push_warning("EquipmentComponent: 重复槽位ID: " + str(config.slot_id))
			continue
		equip_slot_configs[config.slot_id] = config


func _equip_to_slot(equip: GameplayEquipInstance, slot_id: StringName, inventory: InventoryComponent = null, source_index: int = -1) -> bool:
	var config: GameplayEquipSlotConfig = equip_slot_configs.get(slot_id, null)
	if not is_instance_valid(config) or config.equip_type_id != equip.get_equip_type_id():
		return false
	if source_index < -1:
		return false
	var container: Node = equip.get_container()
	if container != null and container != self and container != inventory:
		return false
	if source_index >= 0:
		if not is_instance_valid(inventory) or inventory.get_item(source_index) != equip:
			return false
	elif container == inventory and is_instance_valid(inventory):
		source_index = inventory.items.find(equip)
		if source_index < 0:
			return false
	var previous_slot: StringName = _find_equipped_slot(equip)
	if container == self and previous_slot.is_empty():
		return false
	if previous_slot == slot_id:
		return true
	var old_equip: GameplayEquipInstance = get_equip(slot_id)

	# 已装备实例在同类型槽间移动：占用目标时交换，两个实例均保留。
	if not previous_slot.is_empty():
		if is_instance_valid(old_equip):
			equipped_items[previous_slot] = old_equip
		else:
			equipped_items.erase(previous_slot)
		equipped_items[slot_id] = equip
		equip_changed.emit(previous_slot, old_equip)
		equip_changed.emit(slot_id, equip)
		return true

	# 背包来源槽已验证，交换到此槽不需要额外空位。提交后才通知UI。
	if source_index >= 0:
		if is_instance_valid(old_equip):
			old_equip.release_container(self)
		if not inventory.replace_item_at(source_index, equip, old_equip, false):
			if is_instance_valid(old_equip):
				old_equip.claim_container(self)
			return false
		equipped_items[slot_id] = equip
		equip.claim_container(self)
		inventory.notify_slot_updated(source_index)
		equip_changed.emit(slot_id, equip)
		return true

	# 外部装备替换时，旧装备必须有去处，不能覆盖丢失。
	if is_instance_valid(old_equip):
		if not is_instance_valid(inventory) or not inventory.has_capacity_for(old_equip):
			return false
	equipped_items[slot_id] = equip
	equip.claim_container(self)
	if is_instance_valid(old_equip):
		old_equip.release_container(self)
		if not inventory.add_item(old_equip):
			equipped_items[slot_id] = old_equip
			old_equip.claim_container(self)
			equip.release_container(self)
			return false
	equip_changed.emit(slot_id, equip)
	return true


func _find_equipped_slot(equip: GameplayEquipInstance) -> StringName:
	for slot_id: StringName in equipped_items:
		if equipped_items[slot_id] == equip:
			return slot_id
	return ""


func _find_matching_slot(equip_type: GameplayEquipType) -> StringName:
	var occupied: StringName = ""
	for slot_id: StringName in equip_slot_configs:
		var config: GameplayEquipSlotConfig = equip_slot_configs[slot_id]
		if config.equip_type_id != equip_type.type_id:
			continue
		if get_equip(slot_id) == null:
			return slot_id
		if occupied.is_empty():
			occupied = slot_id
	return occupied


static func get_equipment_component(node: Node) -> EquipmentComponent:
	if not is_instance_valid(node):
		return null
	if node.has_method("get_equipment_component"):
		return node.get_equipment_component() as EquipmentComponent
	return null
