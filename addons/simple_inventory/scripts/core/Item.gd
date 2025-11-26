extends Resource
class_name Item

enum ITEM_TYPE {
	NONE,
	CONSUMABLE,	# 消耗品
	EQUIPMENT,	# 装备
	MATERIAL,	# 材料
}
# const ITEM_TYPE_CONST : Dictionary = {
	#"NONE" : 0,
	#"CONSUMABLE": 1,	# 消耗品
	#"EQUIPMENT": 2,	# 装备
	#"MATERIAL": 3,	# 材料
#}

# Item的属性
@export var name = "道具名称"
@export var icon: Texture = null
@export var description = "道具描述"
## 道具类型
@export var category : ITEM_TYPE = ITEM_TYPE.NONE # 如 "consumable", "equipment", "material" 等
@export var max_stack := 1
@export var quantity = 1 : 
	set(value):
		quantity_changed.emit(value)
		quantity = clamp(value, 0, max_stack)
@export var weight = 0
@export var attributes = {} # 存储属性如 {"strength": 10, "health": 50}

signal quantity_changed(value: int)

## 是否达到堆叠上限
func is_stack_maxed() -> bool:
	return self.quantity >= self.max_stack

## 道具合并
func merge(other_item: Item) -> bool:
	if self.can_merge_with(other_item) and not self.is_stack_maxed():
		var total_quantity = self.quantity + other_item.quantity
		self.quantity = min(total_quantity, self.max_stack)
		other_item.quantity = max(0, total_quantity - self.max_stack)
#		print("合并道具：", self.quantity, ":", other_item.quantity)
#		if other_item.quantity == 0:
#			other_item.free()
		return true
	return false

## 能否合并
func can_merge_with(other_item: Item) -> bool:
	return self.name == other_item.name
