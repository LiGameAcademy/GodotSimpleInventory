extends TestRunner
class_name TestItemMerger

## ItemMerger 单元测试

func test_item_merger() -> void:
	print("  测试 ItemMerger...")
	
	var merger: ItemMerger = ItemMerger.new()
	
	# 创建测试物品配置
	var item_config1: GameplayItem = GameplayItem.new()
	item_config1.item_id = "item_1"
	item_config1.display_name = "物品1"
	item_config1.max_stack = 10
	
	var item_config2: GameplayItem = GameplayItem.new()
	item_config2.item_id = "item_2"
	item_config2.display_name = "物品2"
	item_config2.max_stack = 5
	
	# 测试1: 合并相同物品
	var items: Array[GameplayItemInstance] = []
	items.append(GameplayItemInstance.new(item_config1, 3))
	items.append(GameplayItemInstance.new(item_config1, 5))
	items.append(GameplayItemInstance.new(item_config1, 2))
	
	var merged: Array[GameplayItemInstance] = merger.merge_items(items)
	assert_less_than(merged.size(), items.size(), "合并后数量应该减少")
	
	# 检查合并后的总数量
	var total_quantity: int = 0
	for item in merged:
		if is_instance_valid(item) and item.item_config.item_id == "item_1":
			total_quantity += item.quantity
	
	assert_equal(total_quantity, 10, "合并后总数量应该为10（达到上限）")
	
	# 测试2: 合并不同物品
	var items2: Array[GameplayItemInstance] = []
	items2.append(GameplayItemInstance.new(item_config1, 3))
	items2.append(GameplayItemInstance.new(item_config2, 2))
	items2.append(GameplayItemInstance.new(item_config1, 4))
	
	var merged2: Array[GameplayItemInstance] = merger.merge_items(items2)
	# 不同物品不应该合并，所以数量应该保持
	var item1_count: int = 0
	var item2_count: int = 0
	for item in merged2:
		if is_instance_valid(item):
			if item.item_config.item_id == "item_1":
				item1_count += 1
			elif item.item_config.item_id == "item_2":
				item2_count += 1
	
	assert_greater_than(item1_count, 0, "应该包含物品1")
	assert_greater_than(item2_count, 0, "应该包含物品2")
	
	# 测试3: 空数组
	var empty_items: Array[GameplayItemInstance] = []
	var merged_empty: Array[GameplayItemInstance] = merger.merge_items(empty_items)
	assert_equal(merged_empty.size(), 0, "空数组应该返回空数组")
	
	# 测试4: 包含null的数组
	var items_with_null: Array[GameplayItemInstance] = []
	items_with_null.append(GameplayItemInstance.new(item_config1, 3))
	items_with_null.append(null)
	items_with_null.append(GameplayItemInstance.new(item_config1, 2))
	
	var merged_with_null: Array[GameplayItemInstance] = merger.merge_items(items_with_null)
	# null应该被过滤掉
	var valid_count: int = 0
	for item in merged_with_null:
		if is_instance_valid(item):
			valid_count += 1
	
	assert_greater_than(valid_count, 0, "应该包含有效物品")
	
	print("  ✓ ItemMerger 测试完成")

