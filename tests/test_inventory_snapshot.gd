extends TestRunner
class_name TestInventorySnapshot

## 存档经JSON往返，错误/重复实例不部分覆盖有效状态。
func test_inventory_snapshot() -> void:
	var potion_config: GameplayItem = GameplayItem.new("snapshot_potion", "consumable", "药水", null, "", 10)
	var sword_config: GameplayEquip = GameplayEquip.new()
	sword_config.item_id = "snapshot_sword"
	sword_config.equip_type_id = "snapshot_weapon"
	ItemManager.register_item_config(potion_config)
	ItemManager.register_item_config(sword_config)
	ItemManager.register_equip_type(GameplayEquipType.new("snapshot_weapon"))
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = 3
	inventory._ready()
	var equipment: EquipmentComponent = _make_equipment()
	var potion: GameplayItemInstance = GameplayItemInstance.new(potion_config, 7)
	potion.current_durability = 50.0
	var sword: GameplayEquipInstance = GameplayEquipInstance.new(sword_config)
	sword.enhancement_level = 3
	sword.enchantments.append(&"fire")
	inventory.add_item(potion, 2)
	equipment.equip_item(sword, "weapon")
	var data: Dictionary = JSON.parse_string(JSON.stringify(InventorySnapshot.capture(inventory, equipment))) as Dictionary
	var target_inventory: InventoryComponent = InventoryComponent.new()
	target_inventory._ready()
	var target_equipment: EquipmentComponent = _make_equipment()
	assert_true(InventorySnapshot.restore(data, target_inventory, target_equipment), "快照通过JSON保存/读取后恢复成功")
	assert_equal(target_inventory.max_slot_count, 3, "恢复容量和空槽布局")
	assert_equal(target_inventory.get_item(2).quantity, 7, "恢复数量")
	assert_equal(target_inventory.get_item(2).current_durability, 50.0, "恢复耐久")
	assert_equal(target_equipment.get_equip("weapon").enhancement_level, 3, "恢复强化等级")
	assert_equal(target_equipment.get_equip("weapon").enchantments, [&"fire"], "恢复附魔ID")
	assert_equal(target_equipment.get_equip("weapon").instance_id, sword.instance_id, "恢复稳定实例ID")
	target_inventory.get_item(2).set_quantity(1)
	assert_equal(potion.quantity, 7, "恢复后的实例独立于原始实例")
	var baseline: String = JSON.stringify(InventorySnapshot.capture(target_inventory, target_equipment))
	var changes: Array[int] = [0]
	target_inventory.item_changed.connect(func() -> void: changes[0] += 1)
	var unknown: Dictionary = data.duplicate(true)
	unknown["items"][2]["item_id"] = "unknown"
	assert_false(InventorySnapshot.restore(unknown, target_inventory, target_equipment), "未知物品拒绝恢复")
	assert_equal(JSON.stringify(InventorySnapshot.capture(target_inventory, target_equipment)), baseline, "未知物品失败不部分覆盖状态")
	var duplicate: Dictionary = data.duplicate(true)
	duplicate["equipment"]["weapon"]["instance_id"] = duplicate["items"][2]["instance_id"]
	assert_false(InventorySnapshot.restore(duplicate, target_inventory, target_equipment), "跨背包/装备重复实例ID拒绝恢复")
	var bad_version: Dictionary = data.duplicate(true)
	bad_version["version"] = 99
	assert_false(InventorySnapshot.restore(bad_version, target_inventory, target_equipment), "未知版本拒绝恢复")
	var bad_quantity: Dictionary = data.duplicate(true)
	bad_quantity["items"][2]["quantity"] = -1
	assert_false(InventorySnapshot.restore(bad_quantity, target_inventory, target_equipment), "负数数量拒绝恢复")
	var bad_slot: Dictionary = data.duplicate(true)
	bad_slot["equipment"]["unknown_slot"] = bad_slot["equipment"].get("weapon")
	assert_false(InventorySnapshot.restore(bad_slot, target_inventory, target_equipment), "未知装备槽拒绝恢复")
	assert_equal(changes[0], 0, "所有恢复失败均不发布变更")
	assert_equal(JSON.stringify(InventorySnapshot.capture(target_inventory, target_equipment)), baseline, "所有恢复失败均保持原状态")
	inventory.free()
	equipment.free()
	target_inventory.free()
	target_equipment.free()
	suite_completed = true


func _make_equipment() -> EquipmentComponent:
	var equipment: EquipmentComponent = EquipmentComponent.new()
	var slot: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
	slot.slot_id = "weapon"
	slot.equip_type_id = "snapshot_weapon"
	equipment.equip_slot_configs_array.append(slot)
	equipment._ready()
	return equipment
