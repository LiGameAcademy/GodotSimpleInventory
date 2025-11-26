extends Node2D

@onready var inventory_panel: InventoryPanel = %InventoryPanel
@onready var line_edit: LineEdit = %LineEdit
@onready var btn_submit: Button = %btn_submit
@onready var player: Player = %player

func _ready() -> void:
	# C_Inventory依赖注入
	inventory_panel.initialize(player)

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

func create_item(item_name: String, item_count: int) -> GameplayItemInstance:
	var res_path : String = "res://src/items/" + item_name + ".tres"
	if not ResourceLoader.exists(res_path): 
		return null
	
	var item_config: Resource = load(res_path)
	if not is_instance_valid(item_config):
		return null
	
	# 确保是 GameplayItem 或 GameplayEquip
	if not item_config is GameplayItem:
		push_error("main: 物品资源类型不正确: " + item_name)
		return null
	
	var config: GameplayItem = item_config as GameplayItem
	
	# 注册到 ItemManager（如果还没有注册）
	if ItemManager and not ItemManager.item_configs.has(config.item_id):
		ItemManager.register_item_config(config)
	
	# 通过 ItemManager 创建实例
	if ItemManager:
		return ItemManager.create_item_instance(config.item_id, item_count)
	
	# 如果 ItemManager 不可用，直接创建实例
	if config is GameplayEquip:
		return GameplayEquipInstance.new(config as GameplayEquip, item_count)
	return GameplayItemInstance.new(config, item_count)

func _on_texture_button_pressed() -> void:
	inventory_panel.open()

func _on_line_edit_text_submitted(new_text: String) -> void:
	process_command(new_text)

func _on_btn_submit_pressed() -> void:
	process_command(line_edit.text)
