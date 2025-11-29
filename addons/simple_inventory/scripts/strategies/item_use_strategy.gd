@abstract
extends RefCounted
class_name ItemUseStrategy

## 使用物品（抽象方法）
## slot_index: 物品在背包中的槽位索引，如果为-1表示未知
@abstract func use_item(item: GameplayItemInstance, user: Node, slot_index: int = -1) -> bool

## 判断使用后是否需要从背包中移除物品
## 默认返回 false，子类可以重写此方法
func should_remove_from_inventory(item: GameplayItemInstance) -> bool:
	return false