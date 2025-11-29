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
## inventory_component: 背包组件，如果提供则在替换装备时将旧装备添加到背包
## source_slot_index: 新装备在背包中的源槽位索引，如果提供则在替换装备时将旧装备放到该位置
func equip_item(equip: GameplayEquipInstance, slot_id: StringName = "", inventory_component: InventoryComponent = null, source_slot_index: int = -1) -> bool:
	if not is_instance_valid(equip):
		push_error("EquipmentComponent: equip is not valid")
		return false
	
	var equip_type: GameplayEquipType = equip.get_equip_type_resource()
	if not is_instance_valid(equip_type):
		push_error("EquipmentComponent: equip type is not valid")
		return false
	
	# 如果指定了槽位ID，直接使用
	if not slot_id.is_empty():
		return _equip_to_slot(equip, slot_id, inventory_component, source_slot_index)
	
	# 查找匹配的槽位
	var target_slot_id: StringName = _find_matching_slot(equip_type)
	if target_slot_id.is_empty():
		push_error("EquipmentComponent: no matching slot found")
		return false
	
	return _equip_to_slot(equip, target_slot_id, inventory_component, source_slot_index)

## 卸载装备
## inventory_component: 背包组件，如果提供则尝试将装备添加到背包，如果背包满了则卸载失败
func unequip_item(slot_id: StringName, inventory_component: InventoryComponent = null) -> bool:
	if not equipped_items.has(slot_id) or not is_instance_valid(equipped_items[slot_id]):
		push_error("EquipmentComponent: slot_id is not valid or missing equipped item")
		return false
	
	var equip: GameplayEquipInstance = equipped_items[slot_id]
	
	# 如果提供了背包组件，尝试将装备添加到背包
	if is_instance_valid(inventory_component):
		if not inventory_component.add_item(equip):
			push_error("EquipmentComponent: 背包已满，无法卸载装备")
			return false
	
	# 从装备栏中移除
	equipped_items.erase(slot_id)
	equip_changed.emit(slot_id, null)
	return true

## 获取装备
func get_equip(slot_id: StringName) -> GameplayEquipInstance:
	return equipped_items.get(slot_id, null)

## 装备到指定槽位
## inventory_component: 背包组件，如果提供则在替换装备时将旧装备添加到背包
## source_slot_index: 新装备在背包中的源槽位索引，如果提供则在替换装备时将旧装备放到该位置
func _equip_to_slot(equip: GameplayEquipInstance, slot_id: StringName, inventory_component: InventoryComponent = null, source_slot_index: int = -1) -> bool:
	# 检查槽位是否存在
	if not equip_slot_configs.has(slot_id):
		push_error("EquipmentComponent: 槽位不存在: " + str(slot_id))
		return false
	
	# 检查该装备是否已经装备在其他槽位上
	for existing_slot_id in equipped_items.keys():
		if equipped_items[existing_slot_id] == equip:
			# 如果装备在另一个槽位上，先卸载（不传 inventory_component，因为装备会立即装备到新槽位）
			unequip_item(existing_slot_id)
			break
	
	# 获取槽位配置
	var config: GameplayEquipSlotConfig = equip_slot_configs[slot_id]
	if not is_instance_valid(config):
		push_error("EquipmentComponent: 槽位配置无效: " + str(slot_id))
		return false
	
	# 检查槽位类型是否匹配
	var equip_type: GameplayEquipType = equip.get_equip_type_resource()
	if not is_instance_valid(equip_type):
		push_error("EquipmentComponent: 装备类型无效")
		return false
	
	var slot_equip_type: GameplayEquipType = config.get_equip_type()
	if not is_instance_valid(slot_equip_type):
		push_error("EquipmentComponent: 槽位装备类型无效")
		return false
	
	if slot_equip_type.type_id != equip_type.type_id:
		push_error("EquipmentComponent: 装备类型不匹配，槽位类型: " + str(slot_equip_type.type_id) + ", 装备类型: " + str(equip_type.type_id))
		return false
	
	# 检查是否允许多个装备（如果不允许且槽位已有装备，需要替换）
	if not config.allow_multiple and equipped_items.has(slot_id):
		var old_equip: GameplayEquipInstance = equipped_items[slot_id]
		if is_instance_valid(old_equip):
			# 如果提供了背包组件，执行替换逻辑
			if is_instance_valid(inventory_component):
				# 步骤1：如果提供了源槽位索引，先将新装备从背包中移除（释放槽位）
				if source_slot_index >= 0 and source_slot_index < inventory_component.items.size():
					var source_item = inventory_component.get_item(source_slot_index)
					if is_instance_valid(source_item) and source_item == equip:
						inventory_component.remove_item(source_slot_index)
				
				# 步骤2：将被替换的旧装备添加回背包（自动查找空槽位，包括刚释放的槽位）
				if not inventory_component.add_item(old_equip):
					push_error("EquipmentComponent: 背包已满，无法替换装备")
					# 如果添加失败，恢复新装备到源槽位（如果之前移除了）
					if source_slot_index >= 0 and source_slot_index < inventory_component.items.size():
						if not is_instance_valid(inventory_component.get_item(source_slot_index)):
							inventory_component.items[source_slot_index] = equip
							inventory_component.item_changed.emit()
					return false
			
			# 从装备栏中移除旧装备
			equipped_items.erase(slot_id)
	
	# 步骤3：装备新装备到目标槽位
	equipped_items[slot_id] = equip
	equip_changed.emit(slot_id, equip)
	return true

## 查找匹配的槽位
## 优先返回空槽位，如果没有空槽位则返回已有装备的槽位（用于替换或继续添加）
func _find_matching_slot(equip_type: GameplayEquipType) -> StringName:
	var equip_type_id: StringName = equip_type.type_id if is_instance_valid(equip_type) else ""
	if equip_type_id.is_empty():
		push_error("EquipmentComponent: equip type id is empty")
		return ""
	
	var empty_slot_id: StringName = ""
	var occupied_slot_id: StringName = ""
	
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
			var is_empty: bool = not equipped_items.has(slot_id)
			var allow_multiple: bool = config.allow_multiple
			
			# 如果槽位为空，优先返回
			if is_empty:
				# 记录第一个空槽位
				if empty_slot_id.is_empty():
					empty_slot_id = slot_id
				# 如果不允许多个，直接返回第一个空槽位（因为只能装备一个）
				if not allow_multiple:
					return slot_id
			# 如果槽位已有装备
			else:
				# 如果不允许多个，记录用于替换
				if not allow_multiple and occupied_slot_id.is_empty():
					occupied_slot_id = slot_id
				# 如果允许多个，记录第一个匹配的槽位（用于继续添加）
				elif allow_multiple and occupied_slot_id.is_empty():
					occupied_slot_id = slot_id
	
	# 优先返回空槽位，如果没有空槽位则返回已有装备的槽位（用于替换或继续添加）
	if not empty_slot_id.is_empty():
		return empty_slot_id
	if not occupied_slot_id.is_empty():
		return occupied_slot_id
	
	return ""

static func get_equipment_component(node: Node) -> EquipmentComponent:
	if node.has_method("get_equipment_component"):
		return node.get_equipment_component()
	return node.get_node_or_null("EquipmentComponent")
