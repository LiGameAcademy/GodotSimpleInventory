extends TestRunner
class_name TestInventoryReceipts

## Verifies committed acquisition notifications without depending on game/UI services.

func test_inventory_receipts() -> void:
	var inventory: InventoryComponent = InventoryComponent.new()
	inventory.max_slot_count = 1
	inventory._ready()
	var config: GameplayItem = GameplayItem.new()
	config.item_id = &"receipt_potion"
	config.max_stack = 10
	ItemManager.register_item_config(config)
	var receipts: Array[Dictionary] = []
	var observed_totals: Array[int] = []
	assert_true(inventory.has_signal("items_received"), "Acquisition signal must exist")
	if not inventory.has_signal("items_received"):
		inventory.free()
		suite_completed = true
		return
	inventory.connect("items_received", func(item_id: StringName, quantity: int) -> void:
		receipts.append({"id": item_id, "quantity": quantity})
		observed_totals.append(inventory.items[0].quantity))
	assert_true(inventory.add_item(GameplayItemInstance.new(config, 3)), "First acquisition succeeds")
	assert_true(inventory.add_item(GameplayItemInstance.new(config, 2)), "Full bag still accepts merge")
	assert_equal(receipts, [{"id": &"receipt_potion", "quantity": 3}, {"id": &"receipt_potion", "quantity": 2}], "Each acquisition reports original incoming amount once")
	assert_equal(observed_totals, [3, 5], "Observers see committed contents")
	var rejected: GameplayItemInstance = GameplayItemInstance.new(config, 6)
	assert_false(inventory.add_item(rejected), "Insufficient capacity rejects whole acquisition")
	assert_equal(rejected.quantity, 6, "Rejected instance stays unchanged")
	assert_equal(receipts.size(), 2, "Rejected acquisition emits nothing")
	assert_false(inventory.add_item(inventory.items[0]), "Already owned instance rejected")
	assert_equal(receipts.size(), 2, "Duplicate insertion emits nothing")
	var equipment: EquipmentComponent = EquipmentComponent.new()
	var snapshot: Dictionary = InventorySnapshot.capture(inventory, equipment)
	assert_true(InventorySnapshot.restore(snapshot, inventory, equipment), "Valid snapshot restores")
	assert_equal(receipts.size(), 2, "Restore never counts as acquisition")
	assert_equal(inventory.items[0].quantity, 5, "Restore preserves stack")
	equipment.free()
	inventory.free()
	suite_completed = true
