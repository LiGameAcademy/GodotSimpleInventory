extends Node

## Exercises the plugin in an empty host, including default UI instance isolation.

var _failures: int = 0
var _checks: int = 0

func _ready() -> void:
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = 1
	add_child(inventory)
	var config: GameplayItem = GameplayItem.new()
	config.item_id = &"distribution_potion"
	config.max_stack = 10
	ItemManager.register_item_config(config)
	var receipts: Array[int] = []
	inventory.items_received.connect(func(_id: StringName, quantity: int) -> void: receipts.append(quantity))
	_check(inventory.add_item(GameplayItemInstance.new(config, 3)), "first acquisition")
	_check(inventory.add_item(GameplayItemInstance.new(config, 2)), "full bag merge")
	_check(receipts == [3, 2], "original acquisition quantities")
	_check(not inventory.add_item(GameplayItemInstance.new(config, 6)), "atomic capacity rejection")
	_check(receipts == [3, 2], "no failed acquisition")
	var equipment: EquipmentComponent = EquipmentComponent.new()
	add_child(equipment)
	var snapshot: Dictionary = JSON.parse_string(JSON.stringify(InventorySnapshot.capture(inventory, equipment))) as Dictionary
	_check(InventorySnapshot.restore(snapshot, inventory, equipment), "JSON snapshot restore")
	_check(receipts == [3, 2], "restore emits no acquisition")
	var panel_scene: PackedScene = load("res://addons/simple_inventory/ui/widgets/inventory_panel.tscn") as PackedScene
	var first: InventoryPanel = panel_scene.instantiate() as InventoryPanel
	var second: InventoryPanel = panel_scene.instantiate() as InventoryPanel
	add_child(first)
	add_child(second)
	var other: InventoryComponent = InventoryComponent.new()
	add_child(other)
	var other_equipment: EquipmentComponent = EquipmentComponent.new()
	add_child(other_equipment)
	first.initialize_components(inventory, equipment, self)
	second.initialize_components(other, other_equipment, self)
	first.close()
	second.open()
	_check(not first.visible and second.visible, "independent panel visibility")
	_check(inventory.items[0].quantity == 5 and other.items[0] == null, "independent inventory state")
	first.queue_free()
	second.queue_free()
	inventory.queue_free()
	other.queue_free()
	equipment.queue_free()
	other_equipment.queue_free()
	await get_tree().process_frame
	print("INVENTORY CONTRACTS: %d checks, %d failures" % [_checks, _failures])
	get_tree().quit(0 if _failures == 0 else 1)

func _check(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("Inventory contract failed: " + label)
