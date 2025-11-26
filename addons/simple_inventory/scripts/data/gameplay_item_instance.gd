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
	return item_config.item_id == other.item_config.item_id

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
		push_error("GameplayItemInstance: quantity is out of range!")
		return
	var old_quantity: int = quantity
	quantity = clamp(value, 0, item_config.max_stack)
	if quantity != old_quantity:
		quantity_changed.emit(quantity)

## 生成实例唯一ID
func _generate_instance_id() -> String:
	return str(Time.get_ticks_msec()) + "_" + str(randi())
