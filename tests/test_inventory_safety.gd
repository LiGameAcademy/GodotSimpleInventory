extends TestRunner
class_name TestInventorySafety

## 开源试点：数量守恒、失败不变与实例隔离的回归。
func test_inventory_safety() -> void:
	_test_partial_merge()
	_test_sparse_shrink()
	_test_atomic_add()
	_test_committed_add_notification()
	_test_remove_notification()
	_test_instance_ownership()
	_test_failed_equip_move()
	_test_full_inventory_replacement()
	suite_completed = true


func _test_partial_merge() -> void:
	var config: GameplayItem = _make_item("safety_potion", 10)
	var items: Array[GameplayItemInstance] = [GameplayItemInstance.new(config, 8), GameplayItemInstance.new(config, 7)]
	var merger: ItemMerger = ItemMerger.new()
	var merged: Array[GameplayItemInstance] = merger.merge_items(items)
	assert_equal(_quantity(merged), 15, "INV-01：8+7部分合并后必须保留15个物品")
	assert_equal(merged.size(), 2, "INV-01：剩余5个必须保留独立堆叠")
	assert_equal(_quantity(merger.merge_items(merged)), 15, "INV-01：重复整理数量守恒")


func _test_sparse_shrink() -> void:
	var inventory: InventoryComponent = _make_inventory(20)
	var item: GameplayItemInstance = GameplayItemInstance.new(_make_item("safety_tail", 1), 1)
	inventory.add_item(item, 19)
	assert_false(inventory.set_max_slot_count(10), "INV-02：尾部有物品时安全缩容必须拒绝")
	assert_equal(inventory.max_slot_count, 20, "INV-02：失败不能修改容量")
	assert_equal(inventory.get_item(19), item, "INV-02：失败不能丢尾槽物品")
	var discarded: Array[GameplayItemInstance] = []
	inventory.items_discarded.connect(func(items: Array[GameplayItemInstance]) -> void: discarded.append_array(items))
	assert_true(inventory.set_max_slot_count(10, true), "INV-02：显式强制缩容成功")
	assert_equal(inventory.max_slot_count, 10, "INV-02：强制缩容提交新容量")
	assert_equal(discarded, [item], "INV-02：被截断实例通过信号交付")
	assert_null(item.get_container(), "INV-02：丢弃实例解除容器归属")
	inventory.free()


func _test_atomic_add() -> void:
	var inventory: InventoryComponent = _make_inventory(1)
	var config: GameplayItem = _make_item("safety_atomic", 10)
	var stored: GameplayItemInstance = GameplayItemInstance.new(config, 8)
	var incoming: GameplayItemInstance = GameplayItemInstance.new(config, 5)
	inventory.add_item(stored)
	var changes: Array[int] = [0]
	inventory.item_changed.connect(func() -> void: changes[0] += 1)
	assert_false(inventory.add_item(incoming), "INV-03：容量不足时原子添加失败")
	assert_equal(stored.quantity, 8, "INV-03：失败不能先把已有堆叠改成10")
	assert_equal(incoming.quantity, 5, "INV-03：失败不能消耗传入物品")
	assert_equal(changes[0], 0, "INV-03：失败不能发布状态变更")
	assert_true(inventory.add_item(GameplayItemInstance.new(config, 2)), "INV-03：恰好可堆叠时即使满槽仍可添加")
	assert_equal(stored.quantity, 10, "INV-03：成功堆叠到上限")
	assert_false(inventory.remove_item_by_id(config.item_id, -2), "INV-03：拒绝负数移除")
	assert_false(inventory.remove_item_by_id(config.item_id, 0), "INV-03：拒绝零数量移除")
	inventory.free()


func _test_committed_add_notification() -> void:
	var inventory: InventoryComponent = _make_inventory(2)
	var config: GameplayItem = _make_item("safety_committed", 10)
	inventory.add_item(GameplayItemInstance.new(config, 8))
	var observed: Array[int] = []
	inventory.item_updated.connect(func(_index: int) -> void: observed.append(inventory.get_item_count(config.item_id)))
	assert_true(inventory.add_item(GameplayItemInstance.new(config, 5)), "INV-03：有空位时完整接收")
	assert_equal(observed, [13], "INV-03：更新回调只观察完整提交的数量")
	inventory.free()


func _test_remove_notification() -> void:
	var inventory: InventoryComponent = _make_inventory(2)
	var config: GameplayItem = _make_item("safety_notification", 10)
	inventory.add_item(GameplayItemInstance.new(config, 5))
	var changes: Array[int] = [0]
	var updated: Array[int] = []
	inventory.item_changed.connect(func() -> void: changes[0] += 1)
	inventory.item_updated.connect(func(index: int) -> void: updated.append(index))
	assert_true(inventory.remove_item_by_id(config.item_id, 2), "INV-03：部分移除成功")
	assert_equal(inventory.get_item_count(config.item_id), 3, "INV-03：剩余3个")
	assert_equal(changes[0], 1, "INV-03：部分移除发一次组件更新")
	assert_equal(updated, [0], "INV-03：部分移除通知正确槽位")
	inventory.free()


func _test_instance_ownership() -> void:
	var config: GameplayItem = _make_item("safety_ownership", 10)
	var item: GameplayItemInstance = GameplayItemInstance.new(config, 3)
	var inventory_a: InventoryComponent = _make_inventory(2)
	var inventory_b: InventoryComponent = _make_inventory(2)
	assert_true(inventory_a.add_item(item), "INV-05：A首次接收实例")
	assert_false(inventory_a.add_item(item), "INV-05：拒绝同一实例重复添加")
	assert_equal(item.quantity, 3, "INV-05：重复添加不能自合并改变数量")
	assert_false(inventory_b.add_item(item), "INV-05：B不能接收仍属于A的实例")
	var independent: GameplayItemInstance = GameplayItemInstance.new(config, 3)
	assert_true(inventory_b.add_item(independent), "INV-05：B可共享只读配置，持有独立实例")
	item.set_quantity(2)
	assert_equal(independent.quantity, 3, "INV-05：修改A不影响B")
	assert_equal(config.max_stack, 10, "INV-05：运行状态不修改配置模板")
	inventory_a.remove_item(0)
	assert_true(inventory_b.add_item(item), "INV-05：从A移除后可转交B")
	assert_false(independent.merge(independent), "INV-05：拒绝自合并")
	var damaged: GameplayItemInstance = GameplayItemInstance.new(config, 1)
	damaged.current_durability = 50.0
	assert_false(independent.can_merge_with(damaged), "INV-05：不同耐久不能普通堆叠")
	inventory_a.free()
	inventory_b.free()


func _test_failed_equip_move() -> void:
	var equipment: EquipmentComponent = _make_equipment()
	var sword: GameplayEquipInstance = _make_equip("safety_move_sword")
	assert_true(equipment.equip_item(sword, "weapon"), "INV-04：首次装备成功")
	var changes: Array[int] = [0]
	equipment.equip_changed.connect(func(_id: StringName, _equip: GameplayEquipInstance) -> void: changes[0] += 1)
	assert_false(equipment.equip_item(sword, "head"), "INV-04：移到不兼容槽失败")
	assert_equal(equipment.get_equip("weapon"), sword, "INV-04：失败后原槽仍持有装备")
	assert_null(equipment.get_equip("head"), "INV-04：失败后目标槽不变")
	assert_equal(changes[0], 0, "INV-04：失败不能先发卸装通知")
	equipment.free()


func _test_full_inventory_replacement() -> void:
	var equipment: EquipmentComponent = _make_equipment()
	var inventory: InventoryComponent = _make_inventory(1)
	var old_sword: GameplayEquipInstance = _make_equip("safety_old_sword")
	var new_sword: GameplayEquipInstance = _make_equip("safety_new_sword")
	equipment.equip_item(old_sword, "weapon")
	inventory.add_item(new_sword)
	assert_false(equipment.equip_item(_make_equip("safety_external_sword"), "weapon", inventory), "INV-04：满背包且无来源槽时拒绝替换")
	assert_equal(equipment.get_equip("weapon"), old_sword, "INV-04：失败保留旧装备")
	assert_equal(inventory.get_item(0), new_sword, "INV-04：失败保留背包")
	assert_false(equipment.equip_item(new_sword, "weapon", inventory, 5), "INV-04：拒绝失效来源索引")
	assert_true(equipment.equip_item(new_sword, "weapon", inventory, 0), "INV-04：释放来源槽后允许满背包替换")
	assert_equal(inventory.get_item(0), old_sword, "INV-04：旧装备回到来源槽")
	assert_equal(equipment.get_equip("weapon"), new_sword, "INV-04：新装备只在装备栏")
	assert_false(inventory.add_item(new_sword), "INV-05：不能重复持有已装备实例")
	equipment.free()
	inventory.free()


func _make_item(id: StringName, max_stack: int) -> GameplayItem:
	var config: GameplayItem = GameplayItem.new()
	config.item_id = id
	config.max_stack = max_stack
	return config


func _make_inventory(size: int) -> InventoryComponent:
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = size
	inventory._ready()
	return inventory


func _make_equip(id: StringName) -> GameplayEquipInstance:
	var config: GameplayEquip = GameplayEquip.new()
	config.item_id = id
	config.equip_type_id = "safety_weapon"
	return GameplayEquipInstance.new(config)


func _make_equipment() -> EquipmentComponent:
	var equipment: EquipmentComponent = EquipmentComponent.new()
	for type_id: StringName in [&"safety_weapon", &"safety_head"]:
		var equip_type: GameplayEquipType = GameplayEquipType.new()
		equip_type.type_id = type_id
		ItemManager.register_equip_type(equip_type)
	var weapon: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
	weapon.slot_id = "weapon"
	weapon.equip_type_id = "safety_weapon"
	var head: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
	head.slot_id = "head"
	head.equip_type_id = "safety_head"
	equipment.equip_slot_configs_array.assign([weapon, head])
	equipment._ready()
	return equipment


func _quantity(items: Array[GameplayItemInstance]) -> int:
	var total: int = 0
	for item: GameplayItemInstance in items:
		total += item.quantity
	return total
