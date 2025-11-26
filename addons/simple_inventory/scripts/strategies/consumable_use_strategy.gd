extends ItemUseStrategy
class_name ConsumableUseStrategy

## 消耗品使用策略

func use_item(item: GameplayItemInstance, user: Node) -> bool:
	if not is_instance_valid(item) or not is_instance_valid(item.item_config):
		return false
	
	# 通过 item_type_id 判断是否为消耗品
	var item_type: GameplayItemType = ItemManager.get_item_type(item.item_config.item_type_id)
	if not is_instance_valid(item_type):
		push_error("ConsumableUseStrategy: item type is not valid")
		return false
	
	# 消耗品使用逻辑
	# 例如：恢复生命值、魔法值等
	# 这里需要根据实际游戏系统实现
	# 例如：user.get_node("HealthComponent").heal(attributes.get("heal", 0))
	var ok = _use_item(item, user)
	if not ok:
		return false
	
	# 减少数量
	item.set_quantity(item.quantity - 1)
	
	return true

## 消耗品使用逻辑(子类实现)
func _use_item(item: GameplayItemInstance, user: Node) -> bool:
	return true