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
var _item_user: Node
var _equipment_component: EquipmentComponent

## 信号
signal item_changed
signal item_added(item: GameplayItemInstance, slot_index: int)
signal item_removed(slot_index: int)
signal item_updated(slot_index: int)
signal max_slot_count_changed(old_count: int, new_count: int)
signal items_discarded(discarded: Array[GameplayItemInstance])

func _ready() -> void:
	items.resize(max_slot_count)

## 由宿主显式提供使用者与装备组件，节点改名或换层级不影响规则。
func initialize(user: Node, equipment: EquipmentComponent = null) -> void:
	_item_user = user
	_equipment_component = equipment

## 设置最大槽位数量（运行时扩容/缩容）
## new_count: 新的最大槽位数量
## force: 强制缩容时通过 items_discarded 显式交付被截断的实例。
## 返回: 是否成功调整
func set_max_slot_count(new_count: int, force: bool = false) -> bool:
	if new_count <= 0:
		push_error("InventoryComponent: max_slot_count must be greater than 0")
		return false
	
	var old_count: int = max_slot_count
	if old_count == new_count:
		return true  # 没有变化，直接返回成功
	
	var discarded: Array[GameplayItemInstance] = []
	for index: int in range(new_count, items.size()):
		if is_instance_valid(items[index]):
			discarded.append(items[index])
	if not force and not discarded.is_empty():
		return false
	for item: GameplayItemInstance in discarded:
		item.release_container(self)
	
	# 调整数组大小
	items.resize(new_count)
	max_slot_count = new_count
	
	# 发射信号
	max_slot_count_changed.emit(old_count, new_count)
	if not discarded.is_empty():
		items_discarded.emit(discarded)
	item_changed.emit()
	
	return true

## 添加物品
## slot_index: 如果指定，尝试将物品添加到指定槽位；如果为-1，则自动查找空槽位
func add_item(item: GameplayItemInstance, slot_index: int = -1) -> bool:
	# false 时实例与组件均不变；组件通知只在整个接收完成后发送。
	if not is_instance_valid(item) or item.get_container() != null or items.has(item):
		return false
	if not has_capacity_for(item):
		return false
	var updated: Array[int] = []
	for index: int in range(items.size()):
		var existing: GameplayItemInstance = items[index]
		if is_instance_valid(existing) and existing.can_merge_with(item) and existing.merge(item):
			updated.append(index)
			if item.quantity <= 0:
				break
	var added_index: int = -1
	if item.quantity > 0:
		added_index = slot_index if slot_index >= 0 and slot_index < items.size() and items[slot_index] == null else get_empty_index()
		items[added_index] = item
		item.claim_container(self)
	for index: int in updated:
		item_updated.emit(index)
	if added_index >= 0:
		item_added.emit(item, added_index)
	item_changed.emit()
	return true

## 仅计算容量，供容器间转交预检；不修改实例或发送信号。
func has_capacity_for(item: GameplayItemInstance) -> bool:
	if not is_instance_valid(item) or not is_instance_valid(item.item_config):
		return false
	if item.quantity <= 0 or item.quantity > item.item_config.max_stack:
		return false
	if get_empty_index() >= 0:
		return true
	var available: int = 0
	for existing: GameplayItemInstance in items:
		if is_instance_valid(existing) and existing.can_merge_with(item):
			available += maxi(0, existing.item_config.max_stack - existing.quantity)
	return available >= item.quantity

## 快照恢复入口；先完整校验，再一次性替换，不保留外部可写数组引用。
func replace_contents(replacement: Array[GameplayItemInstance], notify: bool = true) -> bool:
	if replacement.is_empty():
		return false
	var seen: Array[GameplayItemInstance] = []
	for item: GameplayItemInstance in replacement:
		if item == null:
			continue
		if not is_instance_valid(item.item_config) or item.quantity <= 0 or item.quantity > item.item_config.max_stack:
			return false
		if seen.has(item) or (item.get_container() != null and item.get_container() != self):
			return false
		seen.append(item)
	var old_count: int = max_slot_count
	for item: GameplayItemInstance in items:
		if is_instance_valid(item):
			item.release_container(self)
	items = replacement.duplicate()
	max_slot_count = items.size()
	for item: GameplayItemInstance in items:
		if is_instance_valid(item):
			item.claim_container(self)
	if notify:
		if old_count != max_slot_count:
			max_slot_count_changed.emit(old_count, max_slot_count)
		item_changed.emit()
	return true

## 用于装备交换：校验后替换精确来源槽，可延迟通知到整个操作提交之后。
func replace_item_at(slot_index: int, expected: GameplayItemInstance, replacement: GameplayItemInstance, notify: bool = true) -> bool:
	if slot_index < 0 or slot_index >= items.size() or items[slot_index] != expected:
		return false
	if is_instance_valid(replacement):
		if replacement.get_container() != null or items.has(replacement):
			return false
		if not is_instance_valid(replacement.item_config) or replacement.quantity <= 0:
			return false
		if replacement.quantity > replacement.item_config.max_stack:
			return false
	if is_instance_valid(expected):
		expected.release_container(self)
	items[slot_index] = replacement
	if is_instance_valid(replacement):
		replacement.claim_container(self)
	if notify:
		notify_slot_updated(slot_index)
	return true

func notify_slot_updated(slot_index: int) -> void:
	if is_instance_valid(get_item(slot_index)):
		item_updated.emit(slot_index)
	else:
		item_removed.emit(slot_index)
	item_changed.emit()

## 移除物品
func remove_item(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= items.size():
		push_error("InventoryComponent: 无效的槽位索引: " + str(slot_index))
		return
	
	var item: GameplayItemInstance = items[slot_index]
	if is_instance_valid(item):
		item.release_container(self)
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
	for index: int in range(items.size()):
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
	if quantity <= 0:
		return false
	var total_quantity: int = 0
	var slots_to_remove: Array[int] = []
	
	# 统计该物品的总数量
	for i: int in range(items.size()):
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
	for slot_index: int in slots_to_remove:
		if remaining <= 0:
			break
		var item: GameplayItemInstance = items[slot_index]
		if is_instance_valid(item):
			var remove_amount: int = min(remaining, item.quantity)
			item.set_quantity(item.quantity - remove_amount)
			remaining -= remove_amount
			if item.quantity <= 0:
				item.release_container(self)
				items[slot_index] = null
				item_removed.emit(slot_index)
			else:
				item_updated.emit(slot_index)
	
	item_changed.emit()
	return true

## 检查是否有足够的物品数量
func has_item(item_id: StringName, quantity: int = 1) -> bool:
	var total_quantity: int = 0
	for item: GameplayItemInstance in items:
		if is_instance_valid(item) and is_instance_valid(item.item_config):
			if item.item_config.item_id == item_id:
				total_quantity += item.quantity
	return total_quantity >= quantity

## 获取物品总数量
func get_item_count(item_id: StringName) -> int:
	var total_quantity: int = 0
	for item: GameplayItemInstance in items:
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
	var previous: Array[GameplayItemInstance] = items.duplicate()
	var merged_items: Array[GameplayItemInstance] = _item_merger.merge_items(items)
	for item: GameplayItemInstance in previous:
		if is_instance_valid(item) and not merged_items.has(item):
			item.release_container(self)
	
	items.clear()
	items.resize(max_slot_count)
	
	for i: int in range(min(merged_items.size(), max_slot_count)):
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
	for i: int in range(min(sorted_items.size(), max_slot_count)):
		items[i] = sorted_items[i]

## 使用物品
## user: 使用实体；为空时采用 initialize() 显式提供的使用者。
func use_item(slot_index: int, user: Node = null) -> bool:
	var item: GameplayItemInstance = get_item(slot_index)
	if not is_instance_valid(item) or not is_instance_valid(item.item_config):
		return false
	
	if not is_instance_valid(user):
		user = _item_user
	
	if not is_instance_valid(user):
		push_error("InventoryComponent: use_item 需要显式初始化的使用者")
		return false
	if item is GameplayEquipInstance and is_instance_valid(_equipment_component):
		return _equipment_component.equip_item(item as GameplayEquipInstance, "", self, slot_index)
	
	var strategy: ItemUseStrategy = _get_use_strategy(item)
	if not is_instance_valid(strategy):
		return false
	
	var success: bool = strategy.use_item(item, user, slot_index)
	
	# 如果使用成功
	if success:
		# 由策略决定是否需要从背包中移除物品
		if strategy.should_remove_from_inventory(item):
			# 检查槽位是否还有物品（可能已经在策略中被移除了，比如替换装备时）
			var current_item: GameplayItemInstance = get_item(slot_index)
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
	return null
