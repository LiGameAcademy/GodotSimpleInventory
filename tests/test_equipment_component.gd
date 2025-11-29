extends TestRunner
class_name TestEquipmentComponent

## EquipmentComponent 单元测试

func test_equipment_component() -> void:
	print("  测试 EquipmentComponent...")
	
	# 创建测试场景
	var scene: Node = Node.new()
	var equipment: EquipmentComponent = EquipmentComponent.new()
	scene.add_child(equipment)
	
	# 创建装备类型
	var equip_type: GameplayEquipType = GameplayEquipType.new()
	equip_type.type_id = "test_weapon"
	equip_type.display_name = "测试武器"
	
	if ItemManager:
		ItemManager.register_equip_type(equip_type)
	
	# 创建装备槽位配置
	var slot_config: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
	slot_config.slot_id = "weapon_slot"
	slot_config.display_name = "武器槽"
	slot_config.equip_type_id = "test_weapon"
	slot_config.allow_multiple = false
	
	equipment.equip_slot_configs_array.append(slot_config)
	equipment._ready()  # 手动调用_ready以初始化
	
	# 测试1: 初始化槽位
	assert_greater_than(equipment.equip_slot_configs.size(), 0, "应该初始化槽位配置")
	assert_true(equipment.equip_slot_configs.has("weapon_slot"), "应该包含weapon_slot")
	
	# 创建装备配置和实例
	var equip_config: GameplayEquip = GameplayEquip.new()
	equip_config.item_id = "test_sword"
	equip_config.display_name = "测试剑"
	equip_config.equip_type_id = "test_weapon"
	
	var equip_instance: GameplayEquipInstance = GameplayEquipInstance.new(equip_config, 1)
	
	# 测试2: 装备物品
	var equip_result: bool = equipment.equip_item(equip_instance)
	assert_true(equip_result, "应该能装备物品")
	
	var equipped: GameplayEquipInstance = equipment.get_equip("weapon_slot")
	assert_not_null(equipped, "应该能获取已装备的物品")
	assert_equal(equipped.item_config.item_id, "test_sword", "装备ID应该匹配")
	
	# 测试3: 卸载装备
	var unequip_result: bool = equipment.unequip_item("weapon_slot")
	assert_true(unequip_result, "应该能卸载装备")
	
	var after_unequip: GameplayEquipInstance = equipment.get_equip("weapon_slot")
	assert_null(after_unequip, "卸载后应该为null")
	
	# 测试4: 重新装备
	var equip_result2: bool = equipment.equip_item(equip_instance, "weapon_slot")
	assert_true(equip_result2, "应该能重新装备物品")
	
	# 测试5: 装备到不存在的槽位
	var invalid_equip_result: bool = equipment.equip_item(equip_instance, "invalid_slot")
	assert_false(invalid_equip_result, "不应该能装备到不存在的槽位")
	
	# 验证装备没有因为无效槽位而被添加到任何槽位
	var invalid_equipped: GameplayEquipInstance = equipment.get_equip("invalid_slot")
	assert_null(invalid_equipped, "无效槽位不应该有装备")
	
	# 验证原槽位的装备仍然存在（因为测试4已经装备了）
	var still_equipped: GameplayEquipInstance = equipment.get_equip("weapon_slot")
	assert_not_null(still_equipped, "原槽位的装备应该仍然存在")
	
	# 测试5.5: 验证同一装备不会同时出现在多个槽位
	# 创建一个新的武器槽位（但使用不同的slot_id）
	var weapon_slot2: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
	weapon_slot2.slot_id = "weapon_slot_2"
	weapon_slot2.display_name = "武器槽2"
	weapon_slot2.equip_type_id = "test_weapon"
	weapon_slot2.allow_multiple = false
	
	equipment.equip_slot_configs_array.append(weapon_slot2)
	equipment._initialize_equip_slots()
	
	# 尝试将同一个装备实例装备到第二个槽位
	# 这应该会先卸载第一个槽位的装备，然后装备到第二个槽位
	var equip_to_slot2_result: bool = equipment.equip_item(still_equipped, "weapon_slot_2")
	assert_true(equip_to_slot2_result, "应该能装备到第二个槽位")
	
	# 验证第一个槽位已经被清空
	var slot1_equipped: GameplayEquipInstance = equipment.get_equip("weapon_slot")
	assert_null(slot1_equipped, "第一个槽位应该被清空")
	
	# 验证第二个槽位有装备
	var slot2_equipped: GameplayEquipInstance = equipment.get_equip("weapon_slot_2")
	assert_not_null(slot2_equipped, "第二个槽位应该有装备")
	assert_equal(slot2_equipped.item_config.item_id, "test_sword", "第二个槽位的装备ID应该匹配")
	
	# 测试6: 多槽位装备（戒指）
	var ring_type: GameplayEquipType = GameplayEquipType.new()
	ring_type.type_id = "test_ring"
	ring_type.display_name = "测试戒指"
	ring_type.allow_multiple = true
	
	if ItemManager:
		ItemManager.register_equip_type(ring_type)
	
	var ring_slot1: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
	ring_slot1.slot_id = "ring_slot_1"
	ring_slot1.display_name = "戒指槽1"
	ring_slot1.equip_type_id = "test_ring"
	ring_slot1.allow_multiple = true
	
	var ring_slot2: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
	ring_slot2.slot_id = "ring_slot_2"
	ring_slot2.display_name = "戒指槽2"
	ring_slot2.equip_type_id = "test_ring"
	ring_slot2.allow_multiple = true
	
	equipment.equip_slot_configs_array.append(ring_slot1)
	equipment.equip_slot_configs_array.append(ring_slot2)
	equipment._initialize_equip_slots()
	
	var ring_config: GameplayEquip = GameplayEquip.new()
	ring_config.item_id = "test_ring_item"
	ring_config.display_name = "测试戒指"
	ring_config.equip_type_id = "test_ring"
	
	var ring_instance1: GameplayEquipInstance = GameplayEquipInstance.new(ring_config, 1)
	var ring_instance2: GameplayEquipInstance = GameplayEquipInstance.new(ring_config, 1)
	
	var ring_equip1: bool = equipment.equip_item(ring_instance1)
	assert_true(ring_equip1, "应该能装备第一个戒指")
	
	var ring_equip2: bool = equipment.equip_item(ring_instance2)
	assert_true(ring_equip2, "应该能装备第二个戒指")
	
	# 测试7: 获取不存在的槽位
	var invalid_equip: GameplayEquipInstance = equipment.get_equip("invalid_slot")
	assert_null(invalid_equip, "不存在的槽位应该返回null")
	
	# 清理
	scene.queue_free()
	
	print("  ✓ EquipmentComponent 测试完成")
