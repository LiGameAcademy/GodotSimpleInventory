extends TestRunner
class_name TestInventoryComponent

## InventoryComponent 单元测试

func test_inventory_component() -> void:
	print("  测试 InventoryComponent...")
	
	# 创建测试场景
	var scene: Node = Node.new()
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = 10
	scene.add_child(inventory)
	inventory._ready()  # 手动调用_ready以初始化
	
	# 创建测试物品
	var item_config: GameplayItem = GameplayItem.new()
	item_config.item_id = "test_item"
	item_config.display_name = "测试物品"
	item_config.max_stack = 10
	
	var item1: GameplayItemInstance = GameplayItemInstance.new(item_config, 5)
	var item2: GameplayItemInstance = GameplayItemInstance.new(item_config, 3)
	
	# 测试1: 添加物品
	var add_result: bool = inventory.add_item(item1)
	assert_true(add_result, "应该能添加物品")
	assert_equal(inventory.items.size(), 10, "槽位数量应该为10")
	
	# 检查物品是否在正确位置
	var found: bool = false
	for i in range(inventory.items.size()):
		if is_instance_valid(inventory.items[i]) and inventory.items[i] == item1:
			found = true
			break
	assert_true(found, "物品应该在槽位中")
	
	# 测试2: 堆叠物品
	var add_result2: bool = inventory.add_item(item2)
	assert_true(add_result2, "应该能堆叠相同物品")
	
	# 检查堆叠后的数量
	var stacked_item: GameplayItemInstance = null
	for i in range(inventory.items.size()):
		if is_instance_valid(inventory.items[i]) and inventory.items[i].item_config.item_id == "test_item":
			stacked_item = inventory.items[i]
			break
	
	if stacked_item:
		assert_greater_than(stacked_item.quantity, 5, "堆叠后数量应该增加")
	
	# 测试3: 获取物品
	var slot_index: int = -1
	for i in range(inventory.items.size()):
		if is_instance_valid(inventory.items[i]):
			slot_index = i
			break
	
	if slot_index >= 0:
		var retrieved: GameplayItemInstance = inventory.get_item(slot_index)
		assert_not_null(retrieved, "应该能获取物品")
		assert_equal(retrieved.item_config.item_id, "test_item", "物品ID应该匹配")
	
	# 测试4: 移除物品
	if slot_index >= 0:
		inventory.remove_item(slot_index)
		var after_remove: GameplayItemInstance = inventory.get_item(slot_index)
		assert_null(after_remove, "移除后应该为null")
	
	# 测试5: 获取空索引
	var empty_index: int = inventory.get_empty_index()
	assert_not_equal(empty_index, -1, "应该有空槽位")
	
	# 测试6: 填满背包
	var item_config2: GameplayItem = GameplayItem.new()
	item_config2.item_id = "test_item_2"
	item_config2.display_name = "测试物品2"
	item_config2.max_stack = 1
	
	for i in range(inventory.max_slot_count):
		var item: GameplayItemInstance = GameplayItemInstance.new(item_config2, 1)
		inventory.add_item(item)
	
	var full_empty_index: int = inventory.get_empty_index()
	assert_equal(full_empty_index, -1, "背包满时应该返回-1")
	
	# 测试7: 通过ID添加物品（先清空一些槽位以便测试）
	# 清空前3个槽位
	for i in range(3):
		inventory.remove_item(i)
	
	if ItemManager:
		var test_item_config: GameplayItem = GameplayItem.new()
		test_item_config.item_id = "test_id_item"
		test_item_config.display_name = "ID测试物品"
		test_item_config.max_stack = 10
		ItemManager.register_item_config(test_item_config)
		
		var add_by_id_result: bool = inventory.add_item_by_id("test_id_item", 3)
		assert_true(add_by_id_result, "应该能通过ID添加物品")
		
		# 验证物品确实被添加
		var has_item: bool = inventory.has_item("test_id_item", 3)
		assert_true(has_item, "应该包含添加的物品")
	
	# 测试8: 通过ID移除物品
	if ItemManager:
		var remove_by_id_result: bool = inventory.remove_item_by_id("test_id_item", 2)
		assert_true(remove_by_id_result, "应该能通过ID移除物品")
		
		# 验证物品数量减少
		var item_count: int = inventory.get_item_count("test_id_item")
		assert_equal(item_count, 1, "移除后应该还剩1个物品")
	
	# 清理
	scene.queue_free()
	
	print("  ✓ InventoryComponent 测试完成")
