extends ItemUseStrategy
class_name EquipUseStrategy

## 装备使用策略

func use_item(item: GameplayItemInstance, user: Node, slot_index: int = -1) -> bool:
	if not is_instance_valid(item) or not is_instance_valid(item.item_config):
		return false
	
	if not item.item_config is GameplayEquip:
		return false
	
	var equipment_comp: EquipmentComponent = EquipmentComponent.get_equipment_component(user)
	if not is_instance_valid(equipment_comp):
		push_error("EquipUseStrategy: user node is not valid or missing EquipmentComponent")
		return false
	
	# 获取背包组件，用于替换装备时将旧装备添加到背包
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(user)
	
	var equip_instance: GameplayEquipInstance = item as GameplayEquipInstance
	if not is_instance_valid(equip_instance):
		var equip_config: GameplayEquip = item.item_config as GameplayEquip
		equip_instance = GameplayEquipInstance.new(equip_config, 1)
	
	return equipment_comp.equip_item(equip_instance, "", inventory_comp, slot_index)

## 装备后需要从背包中移除
func should_remove_from_inventory(item: GameplayItemInstance) -> bool:
	return true
