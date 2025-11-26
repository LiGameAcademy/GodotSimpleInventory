@abstract
extends RefCounted
class_name ItemUseStrategy

## 使用物品（抽象方法）
@abstract func use_item(item: GameplayItemInstance, user: Node) -> bool