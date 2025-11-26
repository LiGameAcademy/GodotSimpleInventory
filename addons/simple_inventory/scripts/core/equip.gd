extends Item
class_name Equip

## 装备类型
enum EQUIP_TYPE {
	## 胸部
	CHEST,
	## 脚
	FEET,
	## 头
	HEAD,
	## 腿
	LEGS,
	## 项链
	NECKLACE,
	## 指环
	RING,
	## 武器
	WEAPON,
}

@export var equip_type : EQUIP_TYPE = EQUIP_TYPE.CHEST
