extends GameplayItemInstance
class_name GameplayEquipInstance

## 装备的强化等级
var enhancement_level: int = 0

## 附魔列表（可选，后续扩展）
var enchantments: Array = []

func _init(config: GameplayEquip, qty: int = 1) -> void:
	if not is_instance_valid(config) or not config is GameplayEquip:
		push_error("GameplayEquipInstance: 配置必须是 GameplayEquip 类型")
		return
	super(config, qty)

## 获取装备类型ID
func get_equip_type_id() -> StringName:
	if not is_instance_valid(item_config) or not item_config is GameplayEquip:
		return ""
	var equip_config: GameplayEquip = item_config as GameplayEquip
	return equip_config.equip_type_id

## 获取装备类型 Resource（通过 ItemManager 查找）
func get_equip_type_resource() -> GameplayEquipType:
	var type_id: StringName = get_equip_type_id()
	if type_id.is_empty():
		return null
	
	return ItemManager.get_equip_type(type_id)

## 比较两个装备实例的排序顺序
## 排序规则：1. item_type.sort_order 2. equip_type.sort_order（如果另一个也是装备） 3. gameplay_item.sort_order 4. item_id
func compare_type_to(other: GameplayItemInstance) -> bool:
	if not is_instance_valid(other) or not is_instance_valid(other.item_config):
		return false
	
	if not ItemManager:
		return false
	
	# 1. 首先比较 item_type.sort_order
	var item_type: GameplayItemType = ItemManager.get_item_type(item_config.item_type_id)
	var other_item_type: GameplayItemType = ItemManager.get_item_type(other.item_config.item_type_id)
	
	if not is_instance_valid(item_type) or not is_instance_valid(other_item_type):
		return false
	
	if item_type.sort_order != other_item_type.sort_order:
		return item_type.sort_order < other_item_type.sort_order
	
	# 2. 如果 item_type.sort_order 相同，且另一个也是装备实例，比较 equip_type.sort_order
	if other is GameplayEquipInstance:
		var other_equip: GameplayEquipInstance = other as GameplayEquipInstance
		
		var equip_type: GameplayEquipType = get_equip_type_resource()
		var other_equip_type: GameplayEquipType = other_equip.get_equip_type_resource()
		
		if is_instance_valid(equip_type) and is_instance_valid(other_equip_type):
			if equip_type.sort_order != other_equip_type.sort_order:
				return equip_type.sort_order < other_equip_type.sort_order
	
	# 3. 比较 gameplay_item.sort_order
	if item_config.sort_order != other.item_config.sort_order:
		return item_config.sort_order < other.item_config.sort_order
	
	# 4. 如果 sort_order 都相同，按 item_id 排序
	return item_config.item_id < other.item_config.item_id