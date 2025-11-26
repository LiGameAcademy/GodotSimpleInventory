extends Node
class_name EquipmentComponent

## 装备槽位配置数组（在编辑器中配置）
@export var equip_slot_configs_array: Array[GameplayEquipSlotConfig] = []

## 装备槽位配置字典（slot_id -> GameplayEquipSlotConfig，运行时使用）
var equip_slot_configs: Dictionary[StringName, GameplayEquipSlotConfig] = {}

## 当前装备实例（slot_id -> GameplayEquipInstance）
var equipped_items: Dictionary[StringName, GameplayEquipInstance] = {}

## 信号
signal equip_changed(slot_id: StringName, equip: GameplayEquipInstance)

func _ready() -> void:
	# 初始化装备槽位
	_initialize_equip_slots()

## 初始化装备槽位（将数组转换为字典）
func _initialize_equip_slots() -> void:
	equip_slot_configs.clear()
	
	for config in equip_slot_configs_array:
		if not is_instance_valid(config):
			continue
		
		if config.slot_id.is_empty():
			push_warning("EquipmentComponent: 槽位配置缺少 slot_id，将跳过")
			continue
		
		if equip_slot_configs.has(config.slot_id):
			push_warning("EquipmentComponent: 槽位ID重复: " + str(config.slot_id) + "，将覆盖")
		
		equip_slot_configs[config.slot_id] = config

## 装备物品
## slot_id: 指定的槽位ID，如果为空则自动查找匹配的槽位
func equip_item(equip: GameplayEquipInstance, slot_id: StringName = "") -> bool:
	if not is_instance_valid(equip):
		push_error("EquipmentComponent: equip is not valid")
		return false
	
	var equip_type: GameplayEquipType = equip.get_equip_type_resource()
	if not is_instance_valid(equip_type):
		push_error("EquipmentComponent: equip type is not valid")
		return false
	
	# 如果指定了槽位ID，直接使用
	if not slot_id.is_empty():
		return _equip_to_slot(equip, slot_id)
	
	# 查找匹配的槽位
	var target_slot_id: StringName = _find_matching_slot(equip_type)
	if target_slot_id.is_empty():
		push_error("EquipmentComponent: no matching slot found")
		return false
	
	return _equip_to_slot(equip, target_slot_id)

## 卸载装备
func unequip_item(slot_id: StringName) -> bool:
	if not equipped_items.has(slot_id) or not is_instance_valid(equipped_items[slot_id]):
		push_error("EquipmentComponent: slot_id is not valid or missing equipped item")
		return false
	
	var equip: GameplayEquipInstance = equipped_items[slot_id]
	equipped_items.erase(slot_id)
	equip_changed.emit(slot_id, null)
	return true

## 装备到指定槽位
func _equip_to_slot(equip: GameplayEquipInstance, slot_id: StringName) -> bool:
	var old_equip: GameplayEquipInstance = equipped_items.get(slot_id)
	equipped_items[slot_id] = equip
	equip_changed.emit(slot_id, equip)
	return true

## 查找匹配的槽位
func _find_matching_slot(equip_type: GameplayEquipType) -> StringName:
	var equip_type_id: StringName = equip_type.type_id if is_instance_valid(equip_type) else ""
	if equip_type_id.is_empty():
		push_error("EquipmentComponent: equip type id is empty")
		return ""
	
	for slot_id in equip_slot_configs.keys():
		var config: GameplayEquipSlotConfig = equip_slot_configs[slot_id]
		if not is_instance_valid(config):
			push_error("EquipmentComponent: config is not valid")
			continue
		
		var slot_equip_type: GameplayEquipType = config.get_equip_type()
		if not is_instance_valid(slot_equip_type):
			push_error("EquipmentComponent: slot equip type is not valid")
			continue
		
		# 通过类型ID匹配
		if slot_equip_type.type_id == equip_type_id:
			# 检查是否允许多个
			var config_allow_multiple: bool = config.allow_multiple
			if config_allow_multiple or not equipped_items.has(slot_id):
				return slot_id
	
	return ""

static func get_equipment_component(node: Node) -> EquipmentComponent:
	if node.has_method("get_equipment_component"):
		return node.get_equipment_component()
	return node.get_node_or_null("EquipmentComponent")
