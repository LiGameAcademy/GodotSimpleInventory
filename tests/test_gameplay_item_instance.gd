extends TestRunner
class_name TestGameplayItemInstance

## GameplayItemInstance 单元测试

func test_gameplay_item_instance() -> void:
	print("  测试 GameplayItemInstance...")
	
	# 创建测试用的物品配置
	var item_config: GameplayItem = GameplayItem.new()
	item_config.item_id = "test_item"
	item_config.display_name = "测试物品"
	item_config.max_stack = 10
	
	# 测试1: 创建实例
	var instance: GameplayItemInstance = GameplayItemInstance.new(item_config, 5)
	assert_not_null(instance, "实例应该被创建")
	assert_equal(instance.quantity, 5, "数量应该为5")
	assert_equal(instance.get_name(), "测试物品", "名称应该正确")
	assert_false(instance.is_stack_maxed(), "不应该达到堆叠上限")
	
	# 测试2: 堆叠上限检查
	instance.quantity = 10
	assert_true(instance.is_stack_maxed(), "应该达到堆叠上限")
	
	instance.quantity = 9
	assert_false(instance.is_stack_maxed(), "不应该达到堆叠上限")
	
	# 测试3: 合并物品
	var instance2: GameplayItemInstance = GameplayItemInstance.new(item_config, 3)
	var can_merge: bool = instance.can_merge_with(instance2)
	assert_true(can_merge, "相同物品应该可以合并")
	
	var merge_result: bool = instance.merge(instance2)
	assert_true(merge_result, "合并应该成功")
	assert_equal(instance.quantity, 10, "合并后数量应该为10（达到上限）")
	assert_equal(instance2.quantity, 2, "剩余数量应该为2")
	
	# 测试4: 合并不同物品
	var item_config2: GameplayItem = GameplayItem.new()
	item_config2.item_id = "test_item_2"
	var instance3: GameplayItemInstance = GameplayItemInstance.new(item_config2, 1)
	var can_merge_different: bool = instance.can_merge_with(instance3)
	assert_false(can_merge_different, "不同物品不应该可以合并")
	
	# 测试5: 设置数量（带验证）
	var instance4: GameplayItemInstance = GameplayItemInstance.new(item_config, 1)
	instance4.set_quantity(5)
	assert_equal(instance4.quantity, 5, "数量应该设置为5")
	
	instance4.set_quantity(15)  # 超过max_stack
	assert_equal(instance4.quantity, 10, "数量应该被限制为max_stack")
	
	instance4.set_quantity(-1)  # 负数
	assert_equal(instance4.quantity, 0, "数量应该被限制为0")
	
	print("  ✓ GameplayItemInstance 测试完成")
