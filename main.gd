extends Node2D

@onready var inventory_panel: InventoryPanel = %InventoryPanel
@onready var line_edit: LineEdit = %LineEdit
@onready var btn_submit: Button = %btn_submit
@onready var player: Player = %player

func _ready() -> void:
	# 初始化测试资源（必须在其他初始化之前）
	_initialize_test_resources()
	
	# C_Inventory依赖注入
	inventory_panel.initialize(player)

## 初始化测试资源
## 创建并注册所有测试所需的物品类型、装备类型和物品配置
func _initialize_test_resources() -> void:
	if not ItemManager:
		push_error("main: ItemManager 未初始化")
		return
	
	# 1. 创建并注册物品类型
	#_register_item_types()
	
	# 2. 创建并注册装备类型
	#_register_equip_types()
	
	# 3. 注册测试物品配置（从资源文件加载）
	_register_test_items()
	
	print("测试资源初始化完成")

## 注册物品类型
func _register_item_types() -> void:
	# 消耗品类型
	var consumable_type: GameplayItemType = GameplayItemType.new("consumable", "消耗品", null, 1, true, 10, "consumable")
	ItemManager.register_item_type(consumable_type)
	
	# 装备类型
	var equip_type: GameplayItemType = GameplayItemType.new("equip", "装备", null, 2, false, 1, "equip")
	ItemManager.register_item_type(equip_type)
	
	# 材料类型
	var material_type: GameplayItemType = GameplayItemType.new("material", "材料", null, 3, true, 99, "material")
	ItemManager.register_item_type(material_type)

## 注册装备类型
func _register_equip_types() -> void:
	# 武器类型
	var weapon_type: GameplayEquipType = GameplayEquipType.new("weapon", "武器", null, false, 1)
	ItemManager.register_equip_type(weapon_type)
	
	# 护甲类型
	var chest_type: GameplayEquipType = GameplayEquipType.new("chest", "护甲", null, false, 2)
	ItemManager.register_equip_type(chest_type)
	
	# 头盔类型
	var head_type: GameplayEquipType = GameplayEquipType.new("head", "头盔", null, false, 3)
	ItemManager.register_equip_type(head_type)
	
	# 护腿类型
	var legs_type: GameplayEquipType = GameplayEquipType.new("legs", "护腿", null, false, 4)
	ItemManager.register_equip_type(legs_type)
	
	# 靴子类型
	var feet_type: GameplayEquipType = GameplayEquipType.new("feet", "靴子", null, false, 5)
	ItemManager.register_equip_type(feet_type)
	
	# 项链类型
	var necklace_type: GameplayEquipType = GameplayEquipType.new("necklace", "项链", null, false, 6)
	ItemManager.register_equip_type(necklace_type)

	# 戒指类型
	var ring_type: GameplayEquipType = GameplayEquipType.new("ring", "戒指", null, true, 7)
	ItemManager.register_equip_type(ring_type)

## 注册测试物品配置（创建测试物品并注册）
func _register_test_items() -> void:
	# 创建消耗品：生命药水
	var potion_health_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/potion_health.tres")
	var potion_health: GameplayItem = GameplayItem.new("potion_health", "consumable", "生命药水", potion_health_icon, "恢复生命值，有股子怪味，但据说对腰子有好处", 10, 1.0)
	ItemManager.register_item_config(potion_health)
	
	# 创建消耗品：魔法药水
	var potion_mana_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/potion_mana.tres")
	var potion_mana: GameplayItem = GameplayItem.new("potion_mana", "consumable", "魔法药水", potion_mana_icon, "恢复魔法值", 10, 1.0)
	ItemManager.register_item_config(potion_mana)
	
	# 创建材料：木材
	var wood_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/wood.tres")
	var wood: GameplayItem = GameplayItem.new("wood", "material", "木材", wood_icon, "可以用来生火，或者盖房子。大自然的馈赠", 99, 3.0)
	ItemManager.register_item_config(wood)
	
	# 创建材料：鸡蛋
	var egg_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/egg.tres")
	var egg: GameplayItem = GameplayItem.new("egg", "material", "鸡蛋", egg_icon, "新鲜的鸡蛋", 20, 0.5)
	ItemManager.register_item_config(egg)
	
	# 创建装备：木剑
	var sword_1_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/sword.tres")
	var sword_1: GameplayEquip = GameplayEquip.new("sword_1", "equip", "木剑", sword_1_icon, "木质的，可以砍树", 1, 10.0, "weapon")
	ItemManager.register_item_config(sword_1)
	
	# 创建装备：铁剑
	var sword_2_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/sword_2.tres")
	var sword_2: GameplayEquip = GameplayEquip.new("sword_2", "equip", "铁剑", sword_2_icon, "锋利的铁剑", 1, 15.0, "weapon")
	ItemManager.register_item_config(sword_2)
	
	# 创建装备：护甲
	var chest_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/equip_chest.tres")
	var chest: GameplayEquip = GameplayEquip.new("chest", "equip", "布甲", chest_icon, "基础的布制护甲", 1, 5.0, "chest")
	ItemManager.register_item_config(chest)
	
	# 创建装备：头盔
	var head_1_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/equip_head.tres")
	var head_1: GameplayEquip = GameplayEquip.new("head_1", "equip", "布帽", head_1_icon, "简单的布制帽子", 1, 2.0, "head")
	ItemManager.register_item_config(head_1)
	
	# 创建装备：护腿
	var legs_1_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/equip_legs.tres")
	var legs_1: GameplayEquip = GameplayEquip.new("legs_1", "equip", "布裤", legs_1_icon, "简单的布制裤子", 1, 3.0, "legs")
	ItemManager.register_item_config(legs_1)
	
	# 创建装备：靴子
	var feet_1_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/equip_feet.tres")
	var feet_1: GameplayEquip = GameplayEquip.new("feet_1", "equip", "布鞋", feet_1_icon, "简单的布制鞋子", 1, 2.0, "feet")
	ItemManager.register_item_config(feet_1)
	
	# 创建装备：项链
	var necklace_1_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/necklace_1.tres")
	var necklace_1: GameplayEquip = GameplayEquip.new("necklace_1", "equip", "铜项链", necklace_1_icon, "普通的铜制项链", 1, 1.0, "necklace")	
	ItemManager.register_item_config(necklace_1)
	
	# 创建装备：戒指1
	var ring_1_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/ring_1.tres")
	var ring_1: GameplayEquip = GameplayEquip.new("ring_1", "equip", "铜戒指", ring_1_icon, "普通的铜制戒指", 1, 0.5, "ring")
	ItemManager.register_item_config(ring_1)
	
	# 创建装备：戒指2
	var ring_2_icon: Texture2D = load("res://addons/simple_inventory/assets/textures/items/ring_2.tres")
	var ring_2: GameplayEquip = GameplayEquip.new("ring_2", "equip", "银戒指", ring_2_icon, "精致的银制戒指", 1, 0.5, "ring")
	ItemManager.register_item_config(ring_2)
	
	print("已创建并注册所有测试物品配置")

## 将字符串转换为指令
func process_command(command: String):
	var parts = command.split(" ")
	if parts.size() == 0:
		return

	var cmd = parts[0]
	var args = parts.slice(1, parts.size())

	if has_method(cmd):
		self.callv(cmd, args)
	else:
		push_warning("未找到指定的命令：", cmd)

func add_item(item_name: String, item_count: String) -> void:
	var _count = int(item_count)
	var item = create_item(item_name, _count)
	if item == null: 
		push_error("can not found item by name: ", item_name)
		return
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(player)
	inventory_comp.add_item(item)
	print_debug("add_item: ", item_name, " count: ", item_count)

func remove_item(slot_index: String) -> void:
	var _index = int(slot_index)
	var inventory_comp: InventoryComponent = player.get_inventory_component()
	inventory_comp.remove_item(_index)
	print_debug("remove_item: slot_index=", _index)

## 通过物品ID移除指定数量的物品
## 用法: remove_item_by_id <item_id> <quantity>
## 示例: remove_item_by_id potion_health 3
func remove_item_by_id(item_id: String, quantity: String) -> void:
	var _quantity = int(quantity)
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(player)
	if not is_instance_valid(inventory_comp):
		push_error("remove_item_by_id: InventoryComponent 未找到")
		return
	
	var result: bool = inventory_comp.remove_item_by_id(item_id, _quantity)
	if result:
		print_debug("remove_item_by_id: ", item_id, " count: ", _quantity, " 成功")
	else:
		push_warning("remove_item_by_id: 移除失败，可能数量不足或物品不存在")

## 整理背包
## 用法: pack_inventory
func pack_inventory() -> void:
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(player)
	if not is_instance_valid(inventory_comp):
		push_error("pack_inventory: InventoryComponent 未找到")
		return
	
	inventory_comp.pack_items()
	print_debug("pack_inventory: 背包已整理")

## 查看背包状态
## 用法: list_inventory
func list_inventory() -> void:
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(player)
	if not is_instance_valid(inventory_comp):
		push_error("list_inventory: InventoryComponent 未找到")
		return
	
	print("========== 背包状态 ==========")
	var item_count: int = 0
	for i in range(inventory_comp.items.size()):
		var item: GameplayItemInstance = inventory_comp.items[i]
		if is_instance_valid(item) and is_instance_valid(item.item_config):
			item_count += 1
			print("槽位 %d: %s x%d" % [i, item.item_config.display_name, item.quantity])
	
	print("总物品数: %d / %d" % [item_count, inventory_comp.max_slot_count])
	print("==============================")

## 查看物品数量
## 用法: get_item_count <item_id>
## 示例: get_item_count potion_health
func get_item_count(item_id: String) -> void:
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(player)
	if not is_instance_valid(inventory_comp):
		push_error("get_item_count: InventoryComponent 未找到")
		return
	
	var count: int = inventory_comp.get_item_count(item_id)
	print("物品 %s 的数量: %d" % [item_id, count])

## 装备物品
## 用法: equip_item <item_id>
## 示例: equip_item sword_1
func equip_item(item_id: String) -> void:
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(player)
	var equipment_comp: EquipmentComponent = EquipmentComponent.get_equipment_component(player)
	
	if not is_instance_valid(inventory_comp) or not is_instance_valid(equipment_comp):
		push_error("equip_item: 组件未找到")
		return
	
	# 在背包中查找物品
	var equip_instance: GameplayEquipInstance = null
	
	for i in range(inventory_comp.items.size()):
		var item: GameplayItemInstance = inventory_comp.items[i]
		if is_instance_valid(item) and is_instance_valid(item.item_config):
			if item.item_config.item_id == item_id:
				if item is GameplayEquipInstance:
					equip_instance = item as GameplayEquipInstance
					break
	
	if not is_instance_valid(equip_instance):
		push_error("equip_item: 未找到装备或不是装备类型: " + item_id)
		return
	
	# 装备物品（传递背包组件，用于替换装备时将旧装备添加到背包）
	var result: bool = equipment_comp.equip_item(equip_instance, "", inventory_comp)
	if result:
		print_debug("equip_item: ", item_id, " 装备成功")
	else:
		push_warning("equip_item: 装备失败（可能是背包已满，无法替换）")

## 卸载装备
## 用法: unequip_item <slot_id>
## 示例: unequip_item weapon_slot
func unequip_item(slot_id: String) -> void:
	var equipment_comp: EquipmentComponent = EquipmentComponent.get_equipment_component(player)
	if not is_instance_valid(equipment_comp):
		push_error("unequip_item: EquipmentComponent 未找到")
		return
	
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(player)
	if not is_instance_valid(inventory_comp):
		push_error("unequip_item: InventoryComponent 未找到")
		return
	
	var result: bool = equipment_comp.unequip_item(StringName(slot_id), inventory_comp)
	if result:
		print_debug("unequip_item: ", slot_id, " 卸载成功")
	else:
		push_warning("unequip_item: 卸载失败")

## 设置背包最大槽位数量（运行时扩容/缩容）
## 用法: expand_inventory <new_count> [force]
## 示例: expand_inventory 30
## 示例: expand_inventory 20 force  # 强制缩小容量（会丢失超出部分的物品）
func expand_inventory(new_count: String, force: String = "") -> void:
	var _new_count: int = int(new_count)
	var _force: bool = force == "force"
	
	var inventory_comp: InventoryComponent = InventoryComponent.get_inventory_component(player)
	if not is_instance_valid(inventory_comp):
		push_error("expand_inventory: InventoryComponent 未找到")
		return
	
	var old_count: int = inventory_comp.max_slot_count
	# 计算当前实际占用的槽位数量
	var occupied_count: int = 0
	for item in inventory_comp.items:
		if is_instance_valid(item):
			occupied_count += 1
	
	var result: bool = inventory_comp.set_max_slot_count(_new_count, _force)
	
	if result:
		print("expand_inventory: 背包容量从 %d 调整为 %d" % [old_count, _new_count])
	else:
		push_warning("expand_inventory: 调整失败，当前有 %d 个物品，但新容量只有 %d。使用 'expand_inventory %d force' 强制调整" % [occupied_count, _new_count, _new_count])

## 查看装备状态
## 用法: list_equipment
func list_equipment() -> void:
	var equipment_comp: EquipmentComponent = EquipmentComponent.get_equipment_component(player)
	if not is_instance_valid(equipment_comp):
		push_error("list_equipment: EquipmentComponent 未找到")
		return
	
	print("========== 装备状态 ==========")
	for slot_id in equipment_comp.equipped_items.keys():
		var equip: GameplayEquipInstance = equipment_comp.equipped_items[slot_id]
		if is_instance_valid(equip) and is_instance_valid(equip.item_config):
			print("槽位 %s: %s" % [slot_id, equip.item_config.display_name])
		else:
			print("槽位 %s: 空" % slot_id)
	print("==============================")

func create_item(item_id: String, item_count: int) -> GameplayItemInstance:
	return ItemManager.create_item_instance(item_id, item_count)
	
func _on_texture_button_pressed() -> void:
	inventory_panel.open()

func _on_line_edit_text_submitted(new_text: String) -> void:
	process_command(new_text)

func _on_btn_submit_pressed() -> void:
	process_command(line_edit.text)
