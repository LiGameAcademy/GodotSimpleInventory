extends RefCounted
class_name InventorySnapshot

## 版本化的背包/装备数据快照；不序列化节点或UI，坏数据不覆盖原状态。
const VERSION: int = 1


static func capture(inventory: InventoryComponent, equipment: EquipmentComponent) -> Dictionary:
	if not is_instance_valid(inventory) or not is_instance_valid(equipment):
		return {}
	var slots: Array = []
	for item: GameplayItemInstance in inventory.items:
		slots.append(_capture_item(item) if is_instance_valid(item) else null)
	var equips: Dictionary = {}
	for slot_id: StringName in equipment.equipped_items:
		equips[str(slot_id)] = _capture_item(equipment.get_equip(slot_id))
	return {"version": VERSION, "max_slots": inventory.max_slot_count, "items": slots, "equipment": equips}


static func restore(data: Dictionary, inventory: InventoryComponent, equipment: EquipmentComponent) -> bool:
	if not is_instance_valid(inventory) or not is_instance_valid(equipment):
		return false
	if data.get("version") != VERSION or not data.get("items") is Array or not data.get("equipment") is Dictionary:
		return false
	var raw_items: Array = data["items"]
	if raw_items.is_empty() or data.get("max_slots") != raw_items.size():
		return false
	var items: Array[GameplayItemInstance] = []
	var equips: Dictionary[StringName, GameplayEquipInstance] = {}
	var instance_ids: Array[String] = []
	for raw: Variant in raw_items:
		if raw == null:
			items.append(null)
			continue
		var item: GameplayItemInstance = _restore_item(raw)
		if item == null or instance_ids.has(item.instance_id):
			return false
		instance_ids.append(item.instance_id)
		items.append(item)
	var raw_equips: Dictionary = data["equipment"]
	for raw_slot: Variant in raw_equips:
		if not raw_slot is String:
			return false
		var slot_id: StringName = StringName(raw_slot)
		var config: GameplayEquipSlotConfig = equipment.equip_slot_configs.get(slot_id, null)
		var item: GameplayEquipInstance = _restore_item(raw_equips[raw_slot]) as GameplayEquipInstance
		if item == null or not is_instance_valid(config) or instance_ids.has(item.instance_id):
			return false
		if item.quantity != 1 or item.get_equip_type_id() != config.equip_type_id:
			return false
		instance_ids.append(item.instance_id)
		equips[slot_id] = item
	# 两边都已完整校验，且创建的实例未被持有。无中间通知，提交后统一刷新。
	var old_count: int = inventory.max_slot_count
	inventory.replace_contents(items, false)
	equipment.replace_contents(equips, false)
	if old_count != inventory.max_slot_count:
		inventory.max_slot_count_changed.emit(old_count, inventory.max_slot_count)
	inventory.item_changed.emit()
	equipment.notify_contents_changed()
	return true


static func _capture_item(item: GameplayItemInstance) -> Dictionary:
	var data: Dictionary = {
		"item_id": str(item.item_config.item_id), "instance_id": item.instance_id,
		"quantity": item.quantity, "durability": item.current_durability,
	}
	if item is GameplayEquipInstance:
		var equip: GameplayEquipInstance = item as GameplayEquipInstance
		data["enhancement"] = equip.enhancement_level
		data["enchantments"] = equip.enchantments.duplicate()
	return data


static func _restore_item(raw: Variant) -> GameplayItemInstance:
	if not raw is Dictionary:
		return null
	var data: Dictionary = raw
	if not data.get("item_id") is String or not data.get("instance_id") is String:
		return null
	var item_id: StringName = StringName(data["item_id"])
	var instance_id: String = data["instance_id"]
	var config: GameplayItem = ItemManager.item_configs.get(item_id, null)
	if not is_instance_valid(config) or instance_id.is_empty():
		return null
	if not _is_integer(data.get("quantity")):
		return null
	var quantity: int = int(data["quantity"])
	if quantity <= 0 or quantity > config.max_stack:
		return null
	var raw_durability: Variant = data.get("durability")
	if not raw_durability is float and not raw_durability is int:
		return null
	var durability: float = float(raw_durability)
	if not is_finite(durability) or durability < 0.0:
		return null
	var item: GameplayItemInstance
	if config is GameplayEquip:
		if quantity != 1 or not _is_integer(data.get("enhancement", 0)):
			return null
		if int(data.get("enhancement", 0)) < 0 or not data.get("enchantments", []) is Array:
			return null
		var enchantments: Array = data.get("enchantments", [])
		for enchantment: Variant in enchantments:
			if not enchantment is String and not enchantment is StringName:
				return null
		var equip: GameplayEquipInstance = GameplayEquipInstance.new(config as GameplayEquip)
		equip.enhancement_level = int(data.get("enhancement", 0))
		for enchantment: Variant in enchantments:
			equip.enchantments.append(StringName(enchantment))
		item = equip
	else:
		item = GameplayItemInstance.new(config, quantity)
	item.instance_id = instance_id
	item.current_durability = durability
	return item


static func _is_integer(value: Variant) -> bool:
	if value is int:
		return true
	return value is float and is_finite(value) and value == floor(value)
