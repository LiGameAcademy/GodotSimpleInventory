extends TestRunner

## 两套真实默认UI，隐藏、重绑及点击只影响绑定组件。
func _ready() -> void:
	var panel_scene: PackedScene = load("res://addons/simple_inventory/ui/widgets/inventory_panel.tscn") as PackedScene
	var panel_a: InventoryPanel = panel_scene.instantiate() as InventoryPanel
	var panel_b: InventoryPanel = panel_scene.instantiate() as InventoryPanel
	add_child(panel_a)
	add_child(panel_b)
	var inventory_a: InventoryComponent = InventoryComponent.new()
	var inventory_b: InventoryComponent = InventoryComponent.new()
	var equipment_a: EquipmentComponent = _make_equipment()
	var equipment_b: EquipmentComponent = _make_equipment()
	add_child(inventory_a)
	add_child(inventory_b)
	add_child(equipment_a)
	add_child(equipment_b)
	panel_a.initialize_components(inventory_a, equipment_a, self)
	panel_b.initialize_components(inventory_b, equipment_b, self)
	panel_b.hide()
	var config: GameplayEquip = GameplayEquip.new()
	config.item_id = "ui_sword"
	config.equip_type_id = "weapon"
	var sword_a: GameplayEquipInstance = GameplayEquipInstance.new(config)
	var sword_b: GameplayEquipInstance = GameplayEquipInstance.new(config)
	equipment_a.equip_item(sword_a, "weapon")
	equipment_b.equip_item(sword_b, "weapon")
	assert_true(panel_b.equipment_widget.equip_slots.has("weapon"), "隐藏面板仍能发现自己的槽位")
	assert_true(panel_a.equipment_widget.equip_slots["weapon"] != panel_b.equipment_widget.equip_slots["weapon"], "A/B不共享全树槽引用")
	panel_a.equipment_widget.equip_slots["weapon"].mouse_button_right_pressed.emit(sword_a)
	assert_null(equipment_a.get_equip("weapon"), "A右键卸装")
	assert_equal(inventory_a.get_item(0), sword_a, "A卸装回到A背包")
	assert_equal(equipment_b.get_equip("weapon"), sword_b, "B隐藏时装备保持不变")
	assert_null(inventory_b.get_item(0), "A操作不写B背包")
	panel_a.initialize_components(inventory_b, equipment_b, self)
	assert_false(equipment_a.equip_changed.is_connected(panel_a.equipment_widget._on_equip_changed), "重绑解除旧装备信号")
	assert_false(inventory_a.item_changed.is_connected(panel_a.inventory_widget._on_item_changed), "重绑解除旧背包信号")
	panel_a.equipment_widget.equip_slots["weapon"].mouse_button_right_pressed.emit(sword_b)
	assert_null(equipment_b.get_equip("weapon"), "重绑后操作新的装备组件")
	assert_equal(inventory_b.get_item(0), sword_b, "重绑后回到新背包")
	print("UI isolation: %d passed, %d failed" % [passed_tests, failed_tests])
	get_tree().quit(0 if failed_tests == 0 else 1)


func _make_equipment() -> EquipmentComponent:
	var equipment: EquipmentComponent = EquipmentComponent.new()
	var slot: GameplayEquipSlotConfig = GameplayEquipSlotConfig.new()
	slot.slot_id = "weapon"
	slot.equip_type_id = "weapon"
	equipment.equip_slot_configs_array.append(slot)
	return equipment
