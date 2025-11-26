extends Node

## 物品配置资源字典（item_id -> GameplayItem）
var item_configs: Dictionary[StringName, GameplayItem] = {}

## 物品类型配置字典（type_id -> GameplayItemType）
var item_types: Dictionary[StringName, GameplayItemType] = {}

## 装备类型配置字典（type_id -> GameplayEquipType）
var equip_types: Dictionary[StringName, GameplayEquipType] = {}

## 注册物品配置
func register_item_config(item: GameplayItem) -> void:
	if not is_instance_valid(item) or item.item_id.is_empty():
		push_error("ItemManager: 物品配置无效或缺少 item_id")
		return
	if item_configs.has(item.item_id):
		push_warning("ItemManager: 物品配置已存在: " + str(item.item_id) + "，将覆盖原有配置")
	item_configs[item.item_id] = item

## 注册物品类型
func register_item_type(item_type: GameplayItemType) -> void:
	if not is_instance_valid(item_type) or item_type.type_id.is_empty():
		push_error("ItemManager: 物品类型配置无效或缺少 type_id")
		return
	if item_types.has(item_type.type_id):
		push_warning("ItemManager: 物品类型配置已存在: " + str(item_type.type_id) + "，将覆盖原有配置")
	item_types[item_type.type_id] = item_type

## 注册装备类型
func register_equip_type(equip_type: GameplayEquipType) -> void:
	if not is_instance_valid(equip_type) or equip_type.type_id.is_empty():
		push_error("ItemManager: 装备类型配置无效或缺少 type_id")
		return
	if equip_types.has(equip_type.type_id):
		push_warning("ItemManager: 装备类型配置已存在: " + str(equip_type.type_id) + "，将覆盖原有配置")
	equip_types[equip_type.type_id] = equip_type

## 通过 ID 创建物品实例
func create_item_instance(item_id: StringName, quantity: int = 1) -> GameplayItemInstance:
	var config: GameplayItem = item_configs.get(item_id)
	if not is_instance_valid(config):
		push_error("ItemManager: 未找到物品配置: " + str(item_id))
		return null
	return GameplayItemInstance.new(config, quantity)

## 通过 ID 创建装备实例
func create_equip_instance(equip_id: StringName) -> GameplayEquipInstance:
	var config: GameplayItem = item_configs.get(equip_id)
	if not is_instance_valid(config) or not config is GameplayEquip:
		push_error("ItemManager: 未找到装备配置: " + str(equip_id))
		return null
	return GameplayEquipInstance.new(config as GameplayEquip, 1)

## 获取物品配置
func get_item_config(item_id: StringName) -> GameplayItem:
	return item_configs.get(item_id)

## 获取物品类型
func get_item_type(type_id: StringName) -> GameplayItemType:
	return item_types.get(type_id)

## 获取装备类型
func get_equip_type(type_id: StringName) -> GameplayEquipType:
	return equip_types.get(type_id)
