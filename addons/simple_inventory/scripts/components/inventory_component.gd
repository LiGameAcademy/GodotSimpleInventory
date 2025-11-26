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

func _ready() -> void:
	items.resize(max_slot_count)

## 添加物品
func add_item(item: GameplayItemInstance) -> bool:
	if not is_instance_valid(item):
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
	
	# 查找空槽位
	var empty_index: int = get_empty_index()
	if empty_index == -1:
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

## 按类型排序
func sort_items_by_type() -> void:
	var sorted_items: Array[GameplayItemInstance] = _inventory_sorter.sort_by_type(items)
	
	items.clear()
	items.resize(max_slot_count)
	for i in range(min(sorted_items.size(), max_slot_count)):
		items[i] = sorted_items[i]

## 使用物品
func use_item(slot_index: int, user: Node) -> bool:
	var item: GameplayItemInstance = get_item(slot_index)
	if not is_instance_valid(item) or not is_instance_valid(item.item_config):
		return false
	
	var strategy: ItemUseStrategy = _get_use_strategy(item)
	if not is_instance_valid(strategy):
		return false
	
	var success: bool = strategy.use_item(item, user)
	
	# 如果使用后数量为0，移除物品
	if success and item.quantity <= 0:
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
