extends RefCounted
class_name ItemMerger

## 物品合并器

## 合并相同物品
func merge_items(items: Array[GameplayItemInstance]) -> Array[GameplayItemInstance]:
	var result: Array[GameplayItemInstance] = []
	var processed: Array[GameplayItemInstance] = []
	
	for item in items:
		if not is_instance_valid(item) or item in processed:
			continue
		
		var merged: GameplayItemInstance = item
		processed.append(merged)
		
		# 查找可以合并的物品
		for other in items:
			if other == item or other in processed:
				continue
			
			if is_instance_valid(other) and merged.can_merge_with(other) and not merged.is_stack_maxed():
				merged.merge(other)
				processed.append(other)
		
		result.append(merged)
	
	return result
