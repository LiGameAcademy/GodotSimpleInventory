extends TestRunner
class_name TestItemManager

## ItemManager 单元测试

func test_item_manager() -> void:
	print("  测试 ItemManager...")
	
	# 注意：ItemManager是AutoLoad单例，需要确保它已初始化
	if not ItemManager:
		push_error("ItemManager 未初始化，跳过测试")
		return
	
	# 测试1: 注册物品配置
	var item_config: GameplayItem = GameplayItem.new()
	item_config.item_id = "test_item_manager"
	item_config.display_name = "测试物品"
	
	ItemManager.register_item_config(item_config)
	var retrieved: GameplayItem = ItemManager.get_item_config("test_item_manager")
	assert_not_null(retrieved, "应该能获取已注册的物品配置")
	assert_equal(retrieved.item_id, "test_item_manager", "物品ID应该匹配")
	
	# 测试2: 创建物品实例
	var instance: GameplayItemInstance = ItemManager.create_item_instance("test_item_manager", 5)
	assert_not_null(instance, "应该能创建物品实例")
	assert_equal(instance.quantity, 5, "数量应该为5")
	assert_equal(instance.item_config.item_id, "test_item_manager", "配置应该匹配")
	
	# 测试3: 注册物品类型
	var item_type: GameplayItemType = GameplayItemType.new()
	item_type.type_id = "test_type"
	item_type.display_name = "测试类型"
	
	ItemManager.register_item_type(item_type)
	var retrieved_type: GameplayItemType = ItemManager.get_item_type("test_type")
	assert_not_null(retrieved_type, "应该能获取已注册的物品类型")
	assert_equal(retrieved_type.type_id, "test_type", "类型ID应该匹配")
	
	# 测试4: 注册装备类型
	var equip_type: GameplayEquipType = GameplayEquipType.new()
	equip_type.type_id = "test_equip_type"
	equip_type.display_name = "测试装备类型"
	
	ItemManager.register_equip_type(equip_type)
	var retrieved_equip_type: GameplayEquipType = ItemManager.get_equip_type("test_equip_type")
	assert_not_null(retrieved_equip_type, "应该能获取已注册的装备类型")
	assert_equal(retrieved_equip_type.type_id, "test_equip_type", "装备类型ID应该匹配")
	
	# 测试5: 创建装备实例
	var equip_config: GameplayEquip = GameplayEquip.new()
	equip_config.item_id = "test_equip"
	equip_config.display_name = "测试装备"
	equip_config.equip_type_id = "test_equip_type"
	
	ItemManager.register_item_config(equip_config)
	var equip_instance: GameplayEquipInstance = ItemManager.create_equip_instance("test_equip")
	assert_not_null(equip_instance, "应该能创建装备实例")
	assert_true(equip_instance is GameplayEquipInstance, "应该是GameplayEquipInstance类型")
	
	# 测试6: 无效ID
	var invalid_instance: GameplayItemInstance = ItemManager.create_item_instance("invalid_id", 1)
	assert_null(invalid_instance, "无效ID应该返回null")
	
	var invalid_config: GameplayItem = ItemManager.get_item_config("invalid_id")
	assert_null(invalid_config, "无效ID应该返回null")
	
	print("  ✓ ItemManager 测试完成")
