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
			return a.item_config.item_type_id < b.item_config.item_type_id
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
			return a.item_config.display_name < b.item_config.display_name
	)
	return filtered
