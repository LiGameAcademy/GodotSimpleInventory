extends Node2D
class_name Player

func get_equipment_component() -> EquipmentComponent:
	return $EquipmentComponent

func get_inventory_component() -> InventoryComponent:
	return $InventoryComponent
