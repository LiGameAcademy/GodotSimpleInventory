extends TestRunner
class_name TestInventorySorter

## InventorySorter 单元测试

func test_inventory_sorter() -> void:
	print("  测试 InventorySorter...")
	
	var sorter: InventorySorter = InventorySorter.new()
	
	# 首先注册物品类型到 ItemManager（必须在使用排序前完成）
	if not ItemManager:
		push_error("ItemManager 未初始化，跳过测试")
		return
	
	# 创建并注册物品类型
	var item_type_a: GameplayItemType = GameplayItemType.new()
	item_type_a.type_id = "type_a"
	item_type_a.display_name = "类型A"
	item_type_a.sort_order = 1  # 第一个排序
	
	var item_type_b: GameplayItemType = GameplayItemType.new()
	item_type_b.type_id = "type_b"
	item_type_b.display_name = "类型B"
	item_type_b.sort_order = 2  # 第二个排序
	
	var item_type_c: GameplayItemType = GameplayItemType.new()
	item_type_c.type_id = "type_c"
	item_type_c.display_name = "类型C"
	item_type_c.sort_order = 3  # 第三个排序
	
	ItemManager.register_item_type(item_type_a)
	ItemManager.register_item_type(item_type_b)
	ItemManager.register_item_type(item_type_c)
	
	# 创建测试物品配置
	var item_config1: GameplayItem = GameplayItem.new()
	item_config1.item_id = "item_a"
	item_config1.display_name = "物品A"
	item_config1.item_type_id = "type_b"  # 对应 item_type_b (sort_order = 2)
	
	var item_config2: GameplayItem = GameplayItem.new()
	item_config2.item_id = "item_b"
	item_config2.display_name = "物品B"
	item_config2.item_type_id = "type_a"  # 对应 item_type_a (sort_order = 1)
	
	var item_config3: GameplayItem = GameplayItem.new()
	item_config3.item_id = "item_c"
	item_config3.display_name = "物品C"
	item_config3.item_type_id = "type_c"  # 对应 item_type_c (sort_order = 3)
	
	# 测试1: 按类型排序（应该按 sort_order 排序）
	var items: Array[GameplayItemInstance] = []
	items.append(GameplayItemInstance.new(item_config1, 1))  # type_b (sort_order = 2)
	items.append(GameplayItemInstance.new(item_config2, 1))  # type_a (sort_order = 1)
	items.append(GameplayItemInstance.new(item_config3, 1))  # type_c (sort_order = 3)
	
	# 打印排序前的顺序（用于调试）
	print("    排序前: ", items[0].item_config.item_type_id, " (sort_order=", ItemManager.get_item_type(items[0].item_config.item_type_id).sort_order, "), ", 
		  items[1].item_config.item_type_id, " (sort_order=", ItemManager.get_item_type(items[1].item_config.item_type_id).sort_order, "), ", 
		  items[2].item_config.item_type_id, " (sort_order=", ItemManager.get_item_type(items[2].item_config.item_type_id).sort_order, ")")
	
	var sorted_by_type: Array[GameplayItemInstance] = sorter.sort(items)
	assert_equal(sorted_by_type.size(), 3, "排序后数量应该不变")
	
	# 打印排序后的顺序（用于调试）
	if sorted_by_type.size() >= 3:
		print("    排序后: ", sorted_by_type[0].item_config.item_type_id, " (sort_order=", ItemManager.get_item_type(sorted_by_type[0].item_config.item_type_id).sort_order, "), ", 
			  sorted_by_type[1].item_config.item_type_id, " (sort_order=", ItemManager.get_item_type(sorted_by_type[1].item_config.item_type_id).sort_order, "), ", 
			  sorted_by_type[2].item_config.item_type_id, " (sort_order=", ItemManager.get_item_type(sorted_by_type[2].item_config.item_type_id).sort_order, ")")
	
	# 检查排序顺序（应该按 sort_order 排序：type_a(1) < type_b(2) < type_c(3)）
	if sorted_by_type.size() >= 3:
		# 验证排序结果：应该是 type_a, type_b, type_c（按 sort_order 升序）
		var first_type: String = str(sorted_by_type[0].item_config.item_type_id)
		var second_type: String = str(sorted_by_type[1].item_config.item_type_id)
		var third_type: String = str(sorted_by_type[2].item_config.item_type_id)
		
		# 验证 sort_order
		var first_sort_order: int = ItemManager.get_item_type(sorted_by_type[0].item_config.item_type_id).sort_order
		var second_sort_order: int = ItemManager.get_item_type(sorted_by_type[1].item_config.item_type_id).sort_order
		var third_sort_order: int = ItemManager.get_item_type(sorted_by_type[2].item_config.item_type_id).sort_order
		
		assert_true(first_sort_order <= second_sort_order and second_sort_order <= third_sort_order, 
					"排序应该按 sort_order 升序，实际: " + str([first_sort_order, second_sort_order, third_sort_order]))
		
		assert_equal(first_type, "type_a", "第一个应该是type_a (sort_order=1)，实际: " + first_type)
		assert_equal(second_type, "type_b", "第二个应该是type_b (sort_order=2)，实际: " + second_type)
		assert_equal(third_type, "type_c", "第三个应该是type_c (sort_order=3)，实际: " + third_type)
	
	# 测试2: 测试相同类型但不同 sort_order 的物品排序
	# 创建相同类型但不同 sort_order 的物品配置
	var item_config_same_type1: GameplayItem = GameplayItem.new()
	item_config_same_type1.item_id = "item_same_1"
	item_config_same_type1.display_name = "同类型物品1"
	item_config_same_type1.item_type_id = "type_a"  # 相同类型
	item_config_same_type1.sort_order = 2  # 更高的排序优先级
	
	var item_config_same_type2: GameplayItem = GameplayItem.new()
	item_config_same_type2.item_id = "item_same_2"
	item_config_same_type2.display_name = "同类型物品2"
	item_config_same_type2.item_type_id = "type_a"  # 相同类型
	item_config_same_type2.sort_order = 1  # 更低的排序优先级
	
	var items_same_type: Array[GameplayItemInstance] = []
	items_same_type.append(GameplayItemInstance.new(item_config_same_type1, 1))  # sort_order = 2
	items_same_type.append(GameplayItemInstance.new(item_config_same_type2, 1))  # sort_order = 1
	
	var sorted_same_type: Array[GameplayItemInstance] = sorter.sort(items_same_type)
	assert_equal(sorted_same_type.size(), 2, "排序后数量应该不变")
	
	# 检查排序顺序（sort_order 小的应该在前）
	if sorted_same_type.size() >= 2:
		assert_equal(sorted_same_type[0].item_config.sort_order, 1, "第一个应该是 sort_order=1 的物品")
		assert_equal(sorted_same_type[1].item_config.sort_order, 2, "第二个应该是 sort_order=2 的物品")
	
	# 测试3: 空数组
	var empty_items: Array[GameplayItemInstance] = []
	var sorted_empty: Array[GameplayItemInstance] = sorter.sort(empty_items)
	assert_equal(sorted_empty.size(), 0, "空数组应该返回空数组")
	
	# 测试4: 包含null的数组
	var items_with_null: Array[GameplayItemInstance] = []
	items_with_null.append(GameplayItemInstance.new(item_config1, 1))
	items_with_null.append(null)
	items_with_null.append(GameplayItemInstance.new(item_config2, 1))
	
	var sorted_with_null: Array[GameplayItemInstance] = sorter.sort(items_with_null)
	# null应该被过滤掉
	var valid_count: int = 0
	for item in sorted_with_null:
		if is_instance_valid(item):
			valid_count += 1
	
	assert_equal(valid_count, 2, "应该只包含2个有效物品")
	
	print("  ✓ InventorySorter 测试完成")
