extends Node
class_name InventoryComponent

## 库存组件

## 物品槽位数组（使用 GameplayItemInstance）
var items: Array[GameplayItemInstance] = []

## 最大槽位数
@export var max_slot_count: int = 20

var _inventory_sorter: InventorySorter = InventorySorter.new()
var _item_merger: ItemMerger = ItemMerger.new()
var _item_factory: ItemFactory = ItemFactory.new()

## 信号
signal item_changed
signal item_added(item: GameplayItemInstance, slot_index: int)
signal item_removed(slot_index: int)
signal item_updated(slot_index: int)
signal max_slot_count_changed(old_count: int, new_count: int)

func _ready() -> void:
	items.resize(max_slot_count)

## 设置最大槽位数量（运行时扩容/缩容）
## new_count: 新的最大槽位数量
## force: 如果为 true，即使新数量小于当前物品数量也强制调整（会丢失超出部分的物品）
## 返回: 是否成功调整
func set_max_slot_count(new_count: int, force: bool = false) -> bool:
	if new_count <= 0:
		push_error("InventoryComponent: max_slot_count must be greater than 0")
		return false
	
	var old_count: int = max_slot_count
	if old_count == new_count:
		return true  # 没有变化，直接返回成功
	
	# 计算当前实际占用的槽位数量
	var occupied_count: int = 0
	for item in items:
		if is_instance_valid(item):
			occupied_count += 1
	
	# 如果缩小容量且新容量小于当前物品数量，需要处理
	if new_count < old_count and occupied_count > new_count:
		if not force:
			push_error("InventoryComponent: 无法缩小容量，当前有 %d 个物品，但新容量只有 %d。使用 force=true 强制调整（会丢失超出部分的物品）" % [occupied_count, new_count])
			return false
		else:
			push_warning("InventoryComponent: 强制缩小容量，将丢失超出部分的物品")
			# 移除超出部分的物品
			for i in range(new_count, items.size()):
				if is_instance_valid(items[i]):
					items[i] = null
	
	# 调整数组大小
	items.resize(new_count)
	max_slot_count = new_count
	
	# 发射信号
	max_slot_count_changed.emit(old_count, new_count)
	item_changed.emit()
	
	return true

## 添加物品
## slot_index: 如果指定，尝试将物品添加到指定槽位；如果为-1，则自动查找空槽位
func add_item(item: GameplayItemInstance, slot_index: int = -1) -> bool:
	if not is_instance_valid(item):
		push_error("InventoryComponent: 物品无效")
		return false
	
	# 尝试堆叠到现有物品
	for i in range(items.size()):
		var existing_item: GameplayItemInstance = items[i]
		if is_instance_valid(existing_item) and existing_item.can_merge_with(item):
			existing_item.merge(item)
			if item.quantity <= 0:
				item_changed.emit()
				item_updated.emit(i)
				return true
	
	# 如果指定了槽位索引，尝试添加到该槽位
	if slot_index >= 0 and slot_index < items.size():
		if not is_instance_valid(items[slot_index]):
			# 槽位为空，直接添加
			items[slot_index] = item
			item_changed.emit()
			item_added.emit(item, slot_index)
			return true
		# 槽位不为空，继续查找空槽位
	
	# 查找空槽位
	var empty_index: int = get_empty_index()
	if empty_index == -1:
		push_error("InventoryComponent: 没有空槽位")
		return false
	
	items[empty_index] = item
	item_changed.emit()
	item_added.emit(item, empty_index)
	return true

## 移除物品
func remove_item(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= items.size():
		push_error("InventoryComponent: 无效的槽位索引: " + str(slot_index))
		return
	
	items[slot_index] = null
	item_changed.emit()
	item_removed.emit(slot_index)

## 获取物品
func get_item(slot_index: int) -> GameplayItemInstance:
	if slot_index < 0 or slot_index >= items.size():
		return null
	return items[slot_index]

## 获取空的索引
func get_empty_index() -> int:
	for index in range(items.size()):
		if not is_instance_valid(items[index]):
			return index
	return -1

## 根据物品ID和数量添加物品
func add_item_by_id(item_id: StringName, quantity: int = 1) -> bool:
	var item_instance: GameplayItemInstance = _item_factory.create_item(item_id, quantity)
	if not is_instance_valid(item_instance):
		push_error("InventoryComponent: 创建物品失败: " + item_id)
		return false
	return add_item(item_instance)

## 根据物品ID和数量移除物品
func remove_item_by_id(item_id: StringName, quantity: int = 1) -> bool:
	var total_quantity: int = 0
	var slots_to_remove: Array[int] = []
	
	# 统计该物品的总数量
	for i in range(items.size()):
		var item: GameplayItemInstance = items[i]
		if is_instance_valid(item) and is_instance_valid(item.item_config):
			if item.item_config.item_id == item_id:
				total_quantity += item.quantity
				slots_to_remove.append(i)
	
	# 检查是否有足够的数量
	if total_quantity < quantity:
		return false
	
	# 移除物品
	var remaining: int = quantity
	for slot_index in slots_to_remove:
		if remaining <= 0:
			break
		var item: GameplayItemInstance = items[slot_index]
		if is_instance_valid(item):
			var remove_amount: int = min(remaining, item.quantity)
			item.set_quantity(item.quantity - remove_amount)
			remaining -= remove_amount
			if item.quantity <= 0:
				remove_item(slot_index)
	
	return true

## 检查是否有足够的物品数量
func has_item(item_id: StringName, quantity: int = 1) -> bool:
	var total_quantity: int = 0
	for item in items:
		if is_instance_valid(item) and is_instance_valid(item.item_config):
			if item.item_config.item_id == item_id:
				total_quantity += item.quantity
	return total_quantity >= quantity

## 获取物品总数量
func get_item_count(item_id: StringName) -> int:
	var total_quantity: int = 0
	for item in items:
		if is_instance_valid(item) and is_instance_valid(item.item_config):
			if item.item_config.item_id == item_id:
				total_quantity += item.quantity
	return total_quantity

## 背包整理
func pack_items() -> void:
	merge_similar_items()
	sort_items_by_type()
	item_changed.emit()

## 合并相同物品
func merge_similar_items() -> void:
	var merged_items: Array[GameplayItemInstance] = _item_merger.merge_items(items)
	
	items.clear()
	items.resize(max_slot_count)
	
	for i in range(min(merged_items.size(), max_slot_count)):
		items[i] = merged_items[i]

## 设置自定义排序器
## sorter: 自定义的排序器实例，必须实现 sort(items: Array[GameplayItemInstance]) -> Array[GameplayItemInstance] 方法
func set_sorter(sorter: InventorySorter) -> void:
	if not is_instance_valid(sorter):
		push_error("InventoryComponent: 排序器无效")
		return
	_inventory_sorter = sorter

## 按类型排序
func sort_items_by_type() -> void:
	var sorted_items: Array[GameplayItemInstance] = _inventory_sorter.sort(items)
	
	items.clear()
	items.resize(max_slot_count)
	for i in range(min(sorted_items.size(), max_slot_count)):
		items[i] = sorted_items[i]

## 使用物品
## user: 使用物品的实体，如果为null则自动使用组件的所有者（get_parent()）
func use_item(slot_index: int, user: Node = null) -> bool:
	var item: GameplayItemInstance = get_item(slot_index)
	if not is_instance_valid(item) or not is_instance_valid(item.item_config):
		return false
	
	# 如果未指定user，使用组件的所有者
	if not is_instance_valid(user):
		user = get_parent()
	
	if not is_instance_valid(user):
		push_error("InventoryComponent: use_item 需要有效的 user 或组件必须有父节点")
		return false
	
	var strategy: ItemUseStrategy = _get_use_strategy(item)
	if not is_instance_valid(strategy):
		return false
	
	var success: bool = strategy.use_item(item, user, slot_index)
	
	# 如果使用成功
	if success:
		# 由策略决定是否需要从背包中移除物品
		if strategy.should_remove_from_inventory(item):
			# 检查槽位是否还有物品（可能已经在策略中被移除了，比如替换装备时）
			var current_item = get_item(slot_index)
			if is_instance_valid(current_item) and current_item == item:
				remove_item(slot_index)
		# 如果策略不要求移除，但物品数量为0，则移除（如消耗品用完）
		elif item.quantity <= 0:
			remove_item(slot_index)
	
	return success

## 获取使用策略（通过配置的策略ID）
func _get_use_strategy(item: GameplayItemInstance) -> ItemUseStrategy:
	if not is_instance_valid(item) or not is_instance_valid(item.item_config):
		push_error("InventoryComponent: item is not valid or missing item config")
		return null
	
	# 通过 item_type_id 获取物品类型
	var item_type: GameplayItemType = ItemManager.get_item_type(item.item_config.item_type_id)
	if not is_instance_valid(item_type):
		push_error("InventoryComponent: item type is not valid")
		return null
	
	# 从类型配置中获取策略ID
	var strategy_id: StringName = item_type.use_strategy_id
	if strategy_id.is_empty():
		# 如果没有配置策略ID，使用默认判断逻辑
		if item.item_config is GameplayEquip:
			strategy_id = "equip"
		else:
			strategy_id = "consumable"
	
	# 通过 ItemUseStrategyManager 获取策略实例
	if ItemUseStrategyManager:
		return ItemUseStrategyManager.get_strategy(strategy_id)
	
	return null

static func get_inventory_component(entity: Node) -> InventoryComponent:
	if not is_instance_valid(entity):
		return null
	if entity.has_method("get_inventory_component"):
		return entity.get_inventory_component()
	return entity.get_node("InventoryComponent") as InventoryComponent
