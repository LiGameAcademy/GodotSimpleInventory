extends TestRunner
class_name TestIntegration

## 集成测试：测试组件间协作和完整功能流程

func test_integration() -> void:
	print("  测试集成功能...")
	
	# 测试1: 组件协作测试
	test_component_integration()
	
	# 测试2:  
	test_item_add_and_equip_flow()
	
	# 测试3: 物品使用流程
	test_item_use_flow()
	
	# 测试4: 背包整理功能
	test_inventory_pack()
	
	# 测试5: 信号连接测试
	test_signal_connections()
	
	print("  ✓ 集成测试完成")

## 测试1: 组件协作测试
func test_component_integration() -> void:
	print("    测试组件协作...")
	
	# 创建测试场景
	var scene: Node = Node.new()
	var entity: Node = Node.new()
	scene.add_child(entity)
	
	# 创建组件
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = 10
	entity.add_child(inventory)
	inventory._ready()
	
	var equipment: EquipmentComponent = EquipmentComponent.new()
	entity.add_child(equipment)
	
	# 创建装备类型和槽位配置
	if ItemManager:
		var equip_type: GameplayEquipType = GameplayEquipType.new()
		equip_type.type_id = "test_weapon"
		equip_type.display_name = "测试武器"
		ItemManager.register_equip_type(equip_type)
		
		var slot_config: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
		slot_config.slot_id = "weapon_slot"
		slot_config.display_name = "武器槽"
		slot_config.equip_type_id = "test_weapon"
		equipment.equip_slot_configs_array.append(slot_config)
		equipment._ready()
	
	# 创建装备
	var equip_config: GameplayEquip = GameplayEquip.new()
	equip_config.item_id = "test_sword"
	equip_config.display_name = "测试剑"
	equip_config.equip_type_id = "test_weapon"
	
	if ItemManager:
		ItemManager.register_item_config(equip_config)
	
	var equip_instance: GameplayEquipInstance = GameplayEquipInstance.new(equip_config, 1)
	
	# 测试：添加装备到背包，然后装备
	var add_result: bool = inventory.add_item(equip_instance)
	assert_true(add_result, "应该能添加装备到背包")
	
	# 从背包获取装备
	var slot_index: int = -1
	for i in range(inventory.items.size()):
		if is_instance_valid(inventory.items[i]) and inventory.items[i] == equip_instance:
			slot_index = i
			break
	
	assert_not_equal(slot_index, -1, "应该能在背包中找到装备")
	
	# 装备物品
	var equip_result: bool = equipment.equip_item(equip_instance)
	assert_true(equip_result, "应该能装备物品")
	
	# 验证装备已装备
	var equipped: GameplayEquipInstance = equipment.get_equip("weapon_slot")
	assert_not_null(equipped, "应该能获取已装备的物品")
	assert_equal(equipped.item_config.item_id, "test_sword", "装备ID应该匹配")
	
	# 清理
	scene.queue_free()
	
	print("    ✓ 组件协作测试通过")

## 测试2: 物品添加和装备流程
func test_item_add_and_equip_flow() -> void:
	print("    测试物品添加和装备流程...")
	
	var scene: Node = Node.new()
	var entity: Node = Node.new()
	scene.add_child(entity)
	
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = 20
	entity.add_child(inventory)
	inventory._ready()
	
	var equipment: EquipmentComponent = EquipmentComponent.new()
	entity.add_child(equipment)
	
	# 设置装备系统
	if ItemManager:
		var equip_type: GameplayEquipType = GameplayEquipType.new()
		equip_type.type_id = "test_armor"
		equip_type.display_name = "测试护甲"
		ItemManager.register_equip_type(equip_type)
		
		var slot_config: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
		slot_config.slot_id = "armor_slot"
		slot_config.display_name = "护甲槽"
		slot_config.equip_type_id = "test_armor"
		equipment.equip_slot_configs_array.append(slot_config)
		equipment._ready()
	
	# 创建多个物品
	var item_config1: GameplayItem = GameplayItem.new()
	item_config1.item_id = "item_1"
	item_config1.display_name = "物品1"
	item_config1.max_stack = 10
	
	var equip_config: GameplayEquip = GameplayEquip.new()
	equip_config.item_id = "armor_1"
	equip_config.display_name = "护甲1"
	equip_config.equip_type_id = "test_armor"
	
	if ItemManager:
		ItemManager.register_item_config(item_config1)
		ItemManager.register_item_config(equip_config)
	
	# 添加普通物品
	var item1: GameplayItemInstance = GameplayItemInstance.new(item_config1, 5)
	var add_result1: bool = inventory.add_item(item1)
	assert_true(add_result1, "应该能添加普通物品")
	
	# 添加装备
	var equip_instance: GameplayEquipInstance = GameplayEquipInstance.new(equip_config, 1)
	var add_result2: bool = inventory.add_item(equip_instance)
	assert_true(add_result2, "应该能添加装备到背包")
	
	# 装备物品
	var equip_result: bool = equipment.equip_item(equip_instance)
	assert_true(equip_result, "应该能装备物品")
	
	# 验证背包中装备已移除（如果装备系统从背包移除装备）
	# 注意：当前实现中，装备不会自动从背包移除，这是设计选择
	
	# 清理
	scene.queue_free()
	
	print("    ✓ 物品添加和装备流程测试通过")

## 测试3: 物品使用流程
func test_item_use_flow() -> void:
	print("    测试物品使用流程...")
	
	var scene: Node = Node.new()
	var entity: Node = Node.new()
	scene.add_child(entity)
	
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = 20
	entity.add_child(inventory)
	inventory._ready()
	
	var equipment: EquipmentComponent = EquipmentComponent.new()
	entity.add_child(equipment)
	
	# 设置装备系统
	if ItemManager:
		var equip_type: GameplayEquipType = GameplayEquipType.new()
		equip_type.type_id = "test_weapon"
		equip_type.display_name = "测试武器"
		ItemManager.register_equip_type(equip_type)
		
		var slot_config: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
		slot_config.slot_id = "weapon_slot"
		slot_config.display_name = "武器槽"
		slot_config.equip_type_id = "test_weapon"
		equipment.equip_slot_configs_array.append(slot_config)
		equipment._ready()
		
		# 注册物品类型和使用策略
		var item_type: GameplayItemType = GameplayItemType.new()
		item_type.type_id = "equip"
		item_type.display_name = "装备"
		item_type.use_strategy_id = "equip"
		ItemManager.register_item_type(item_type)
	
	# 创建装备
	var equip_config: GameplayEquip = GameplayEquip.new()
	equip_config.item_id = "test_sword"
	equip_config.display_name = "测试剑"
	equip_config.equip_type_id = "test_weapon"
	equip_config.item_type_id = "equip"
	
	if ItemManager:
		ItemManager.register_item_config(equip_config)
	
	var equip_instance: GameplayEquipInstance = GameplayEquipInstance.new(equip_config, 1)
	
	# 添加装备到背包
	var add_result: bool = inventory.add_item(equip_instance)
	assert_true(add_result, "应该能添加装备到背包")
	
	# 找到装备的槽位
	var slot_index: int = -1
	for i in range(inventory.items.size()):
		if is_instance_valid(inventory.items[i]) and inventory.items[i] == equip_instance:
			slot_index = i
			break
	
	assert_not_equal(slot_index, -1, "应该能找到装备的槽位")
	
	# 使用物品（应该自动装备）
	var use_result: bool = inventory.use_item(slot_index, entity)
	assert_true(use_result, "应该能使用装备物品")
	
	# 验证装备已装备
	var equipped: GameplayEquipInstance = equipment.get_equip("weapon_slot")
	assert_not_null(equipped, "使用后应该已装备")
	
	# 清理
	scene.queue_free()
	
	print("    ✓ 物品使用流程测试通过")

## 测试4: 背包整理功能
func test_inventory_pack() -> void:
	print("    测试背包整理功能...")
	
	var scene: Node = Node.new()
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = 10
	scene.add_child(inventory)
	inventory._ready()
	
	# 创建可堆叠物品
	var item_config: GameplayItem = GameplayItem.new()
	item_config.item_id = "test_item"
	item_config.display_name = "测试物品"
	item_config.max_stack = 10
	
	if ItemManager:
		ItemManager.register_item_config(item_config)
	
	# 添加多个相同物品（分散在不同槽位）
	var item1: GameplayItemInstance = GameplayItemInstance.new(item_config, 3)
	var item2: GameplayItemInstance = GameplayItemInstance.new(item_config, 5)
	var item3: GameplayItemInstance = GameplayItemInstance.new(item_config, 2)
	
	inventory.add_item(item1)
	inventory.add_item(item2)
	inventory.add_item(item3)
	
	# 整理背包
	inventory.pack_items()
	
	# 验证物品已合并
	var total_quantity: int = 0
	var item_count: int = 0
	for i in range(inventory.items.size()):
		var item: GameplayItemInstance = inventory.items[i]
		if is_instance_valid(item) and item.item_config.item_id == "test_item":
			total_quantity += item.quantity
			item_count += 1
	
	assert_equal(total_quantity, 10, "物品应该合并，总数量为10")
	assert_less_than(item_count, 3, "物品应该合并，槽位数量应该减少")
	
	# 清理
	scene.queue_free()
	
	print("    ✓ 背包整理功能测试通过")

## 测试5: 信号连接测试
func test_signal_connections() -> void:
	print("    测试信号连接...")
	
	var scene: Node = Node.new()
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = 10
	scene.add_child(inventory)
	inventory._ready()
	
	var equipment: EquipmentComponent = EquipmentComponent.new()
	scene.add_child(equipment)
	
	# 测试信号是否正常发射（使用数组来绕过lambda限制）
	var signal_flags: Dictionary = {
		"item_changed": false,
		"item_added": false,
		"equip_changed": false
	}
	
	inventory.item_changed.connect(func(): signal_flags["item_changed"] = true)
	inventory.item_added.connect(func(_item, _slot): signal_flags["item_added"] = true)
	equipment.equip_changed.connect(func(_slot, _equip): signal_flags["equip_changed"] = true)
	
	# 添加物品
	var item_config: GameplayItem = GameplayItem.new()
	item_config.item_id = "test_item"
	item_config.display_name = "测试物品"
	
	if ItemManager:
		ItemManager.register_item_config(item_config)
	
	var item: GameplayItemInstance = GameplayItemInstance.new(item_config, 1)
	inventory.add_item(item)
	
	# 等待一帧让信号处理
	await scene.get_tree().process_frame
	
	assert_true(signal_flags["item_changed"], "item_changed 信号应该被发射")
	assert_true(signal_flags["item_added"], "item_added 信号应该被发射")
	
	# 测试装备信号
	if ItemManager:
		var equip_type: GameplayEquipType = GameplayEquipType.new()
		equip_type.type_id = "test_weapon"
		ItemManager.register_equip_type(equip_type)
		
		var slot_config: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
		slot_config.slot_id = "weapon_slot"
		slot_config.equip_type_id = "test_weapon"
		equipment.equip_slot_configs_array.append(slot_config)
		equipment._ready()
		
		var equip_config: GameplayEquip = GameplayEquip.new()
		equip_config.item_id = "test_sword"
		equip_config.equip_type_id = "test_weapon"
		ItemManager.register_item_config(equip_config)
		
		var equip_instance: GameplayEquipInstance = GameplayEquipInstance.new(equip_config, 1)
		equipment.equip_item(equip_instance)
		
		await scene.get_tree().process_frame
		
		assert_true(signal_flags["equip_changed"], "equip_changed 信号应该被发射")
	
	# 清理
	scene.queue_free()
	
	print("    ✓ 信号连接测试通过")
