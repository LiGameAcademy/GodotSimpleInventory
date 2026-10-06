extends RefCounted
class_name GameplayItemInstance

## 关联的配置资源
var item_config: GameplayItem

# 运行时状态
## 物品数量
var quantity: int = 1
## 物品耐久度
var current_durability: float = 100.0
## 实例唯一ID
var instance_id: String = ""  # 实例唯一ID
var _container: WeakRef

## 数量变化信号
signal quantity_changed(value: int)

func _init(config: GameplayItem, qty: int = 1) -> void:
	if not is_instance_valid(config):
		push_error("GameplayItemInstance: 配置资源不能为空")
		return
	item_config = config
	quantity = qty
	instance_id = _generate_instance_id()

## 获取物品名称（从配置读取）
func get_name() -> String:
	return item_config.display_name if is_instance_valid(item_config) else ""

## 获取物品图标（从配置读取）
func get_icon() -> Texture2D:
	return item_config.icon if is_instance_valid(item_config) else null

## 是否达到堆叠上限
func is_stack_maxed() -> bool:
	if not is_instance_valid(item_config):
		return true
	return quantity >= item_config.max_stack

## 能否与另一个物品合并
func can_merge_with(other: GameplayItemInstance) -> bool:
	if not is_instance_valid(item_config) or not is_instance_valid(other) or not is_instance_valid(other.item_config):
		push_error("GameplayItemInstance: gameplay item config or other item instance or other item config is not valid")
		return false
	# 装备实例带强化/附魔等独立状态，不参与普通堆叠。
	if other == self or self is GameplayEquipInstance or other is GameplayEquipInstance:
		return false
	return item_config == other.item_config and current_durability == other.current_durability

## 一个运行实例只能属于一个背包或装备组件；容器释放后不会被实例保活。
func get_container() -> Node:
	return _container.get_ref() as Node if _container != null else null

func claim_container(container: Node) -> bool:
	if not is_instance_valid(container) or get_container() != null:
		return false
	_container = weakref(container)
	return true

func release_container(container: Node) -> void:
	if get_container() == container:
		_container = null

## 合并物品
func merge(other: GameplayItemInstance) -> bool:
	if not can_merge_with(other) or is_stack_maxed():
		return false
	
	var total_quantity: int = quantity + other.quantity
	var max_stack: int = item_config.max_stack
	
	quantity = min(total_quantity, max_stack)
	other.quantity = max(0, total_quantity - max_stack)
	
	# 发射信号
	quantity_changed.emit(quantity)
	if other.quantity > 0:
		other.quantity_changed.emit(other.quantity)
	
	return true

## 设置数量（带验证和信号）
func set_quantity(value: int) -> void:
	if not is_instance_valid(item_config):
		push_error("GameplayItemInstance: gameplay item config is not valid!")
		return
	if value < 0 or value > item_config.max_stack:
		push_warning("GameplayItemInstance: quantity is out of range!")
	var old_quantity: int = quantity
	quantity = clamp(value, 0, item_config.max_stack)
	if quantity != old_quantity:
		quantity_changed.emit(quantity)

## 比较两个物品实例的排序顺序
## other: 另一个物品实例
## 返回 true 表示当前物品应该排在前面，false 表示应该排在后面
## 排序规则：1. item_type.sort_order 2. gameplay_item.sort_order 3. item_id
func compare_type_to(other: GameplayItemInstance) -> bool:
	if not is_instance_valid(other) or not is_instance_valid(other.item_config):
		return false
	
	if not ItemManager:
		return false
	
	var item_type: GameplayItemType = ItemManager.get_item_type(item_config.item_type_id)
	var other_item_type: GameplayItemType = ItemManager.get_item_type(other.item_config.item_type_id)
	
	if not is_instance_valid(item_type) or not is_instance_valid(other_item_type):
		return false
	
	# 1. 首先比较 item_type.sort_order
	if item_type.sort_order != other_item_type.sort_order:
		return item_type.sort_order < other_item_type.sort_order
	
	# 2. 如果 item_type.sort_order 相同，比较 gameplay_item.sort_order
	if item_config.sort_order != other.item_config.sort_order:
		return item_config.sort_order < other.item_config.sort_order
	
	# 3. 如果 sort_order 都相同，按 item_id 排序
	return item_config.item_id < other.item_config.item_id

## 生成实例唯一ID
func _generate_instance_id() -> String:
	return str(Time.get_ticks_msec()) + "_" + str(randi())
