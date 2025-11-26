extends RefCounted
class_name ItemFactory

## 物品工厂

## 通过 ID 创建物品实例
func create_item(item_id: StringName, quantity: int = 1) -> GameplayItemInstance:
	if not ItemManager:
		push_error("ItemFactory: ItemManager is not initialized")
		return null
	return ItemManager.create_item_instance(item_id, quantity)

## 通过配置资源创建实例
func create_item_from_config(config: GameplayItem, quantity: int = 1) -> GameplayItemInstance:
	if not is_instance_valid(config):
		return null
	
	if config is GameplayEquip:
		return GameplayEquipInstance.new(config as GameplayEquip, quantity)
	return GameplayItemInstance.new(config, quantity)
