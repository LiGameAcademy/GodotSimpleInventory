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
