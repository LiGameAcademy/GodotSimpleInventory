extends RefCounted
class_name InventorySorter

## 库存排序器

## 按类型排序
func sort_by_type(items: Array[GameplayItemInstance]) -> Array[GameplayItemInstance]:
	var filtered: Array[GameplayItemInstance] = items.filter(func(item): return is_instance_valid(item))
	filtered.sort_custom(
		func(a: GameplayItemInstance, b: GameplayItemInstance) -> bool:
			if not is_instance_valid(a) or not is_instance_valid(b):
				return false
			if not is_instance_valid(a.item_config) or not is_instance_valid(b.item_config):
				return false
			
			# 通过 ItemManager 获取物品类型资源
			var a_type_id: StringName = a.item_config.item_type_id
			var b_type_id: StringName = b.item_config.item_type_id
			
			# 获取物品类型资源
			var a_item_type: GameplayItemType = null
			var b_item_type: GameplayItemType = null
			
			if ItemManager:
				a_item_type = ItemManager.get_item_type(a_type_id)
				b_item_type = ItemManager.get_item_type(b_type_id)
			
			# 获取 sort_order（如果类型不存在，使用默认值 0）
			var a_sort_order: int = a_item_type.sort_order if is_instance_valid(a_item_type) else 0
			var b_sort_order: int = b_item_type.sort_order if is_instance_valid(b_item_type) else 0
			
			# 首先按 sort_order 排序（升序）
			if a_sort_order != b_sort_order:
				return a_sort_order < b_sort_order
			
			# 如果 sort_order 相同，按 type_id 排序（作为次要排序条件）
			var a_type_str: String = str(a_type_id)
			var b_type_str: String = str(b_type_id)
			return a_type_str < b_type_str
	)
	return filtered

## 按名称排序
func sort_by_name(items: Array[GameplayItemInstance]) -> Array[GameplayItemInstance]:
	var filtered: Array[GameplayItemInstance] = items.filter(func(item): return is_instance_valid(item))
	filtered.sort_custom(
		func(a: GameplayItemInstance, b: GameplayItemInstance) -> bool:
			if not is_instance_valid(a) or not is_instance_valid(b):
				return false
			if not is_instance_valid(a.item_config) or not is_instance_valid(b.item_config):
				return false
			# display_name 已经是 String 类型，可以直接比较
			return a.item_config.display_name < b.item_config.display_name
	)
	return filtered
