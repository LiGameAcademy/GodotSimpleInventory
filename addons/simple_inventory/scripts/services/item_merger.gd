extends RefCounted
class_name ItemMerger

## 物品合并器

## 合并相同物品
func merge_items(items: Array[GameplayItemInstance]) -> Array[GameplayItemInstance]:
	var result: Array[GameplayItemInstance] = []
	var processed: Array[GameplayItemInstance] = []
	
	for item: GameplayItemInstance in items:
		if not is_instance_valid(item) or item in processed:
			continue
		if item.quantity <= 0:
			continue
		
		var merged: GameplayItemInstance = item
		processed.append(merged)
		
		# 查找可以合并的物品
		for other: GameplayItemInstance in items:
			if other == item or other in processed:
				continue
			
			if is_instance_valid(other) and merged.can_merge_with(other) and not merged.is_stack_maxed():
				merged.merge(other)
				# 只有完全消耗的堆叠才跳过；部分剩余还要进入结果。
				if other.quantity <= 0:
					processed.append(other)
		
		result.append(merged)
	
	return result
