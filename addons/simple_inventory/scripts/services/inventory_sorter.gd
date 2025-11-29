extends RefCounted
class_name InventorySorter

## 库存排序器
## 排序规则：优先按道具类型排序、同类型按道具排序规则排序（gameplay_item.sort_order）、最终以 item_id 进行最终排序

## 排序物品
## 排序规则：
## 1. item_type.sort_order（道具类型排序优先级）
## 2. equip_type.sort_order（如果是装备，装备类型排序优先级）
## 3. gameplay_item.sort_order（道具排序优先级）
## 4. item_id（最终排序）
func sort(items: Array[GameplayItemInstance]) -> Array[GameplayItemInstance]:
	var filtered: Array[GameplayItemInstance] = items.filter(func(item): return is_instance_valid(item))
	filtered.sort_custom(
		func(a: GameplayItemInstance, b: GameplayItemInstance) -> bool:
			if not is_instance_valid(a) or not is_instance_valid(b):
				return false
			if not is_instance_valid(a.item_config) or not is_instance_valid(b.item_config):
				return false

			return a.compare_type_to(b)
	)
	return filtered
