extends Resource
class_name GameplayEquipSlotConfig

## 槽位名称
@export var slot_name: StringName = ""

## 装备类型ID（引用 GameplayEquipType）
@export var equip_type_id: StringName = ""

## 是否允许多个装备（如戒指槽位）
@export var allow_multiple: bool = false

## 获取装备类型 Resource（通过 ItemManager 查找）
## 注意：需要 ItemManager 已配置为 AutoLoad 单例
func get_equip_type() -> GameplayEquipType:
	if equip_type_id.is_empty():
		return null
	
	return ItemManager.get_equip_type(equip_type_id)
