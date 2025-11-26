extends ItemUseStrategy
class_name EquipUseStrategy

## 装备使用策略

func use_item(item: GameplayItemInstance, user: Node) -> bool:
	if not is_instance_valid(item) or not is_instance_valid(item.item_config):
		return false
	
	if not item.item_config is GameplayEquip:
		return false
	
	var equipment_comp: EquipmentComponent = EquipmentComponent.get_equipment_component(user)
	if not is_instance_valid(equipment_comp):
		push_error("EquipUseStrategy: user node is not valid or missing EquipmentComponent")
		return false
	
	var equip_instance: GameplayEquipInstance = item as GameplayEquipInstance
	if not is_instance_valid(equip_instance):
		var equip_config: GameplayEquip = item.item_config as GameplayEquip
		equip_instance = GameplayEquipInstance.new(equip_config, 1)
	
	return equipment_comp.equip_item(equip_instance)
