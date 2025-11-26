@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("ItemManager", "scripts/managers/item_manager.gd")
	add_autoload_singleton("ItemUseStrategyManager", "scripts/managers/item_use_strategy_manager.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("ItemManager")
	remove_autoload_singleton("ItemUseStrategyManager")
