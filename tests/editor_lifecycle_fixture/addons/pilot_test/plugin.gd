@tool
extends EditorPlugin

var _failures: int = 0

func _enter_tree() -> void:
	call_deferred("_run")

func _run() -> void:
	while get_editor_interface().get_resource_filesystem().is_scanning():
		await get_tree().process_frame
	var phase: int = ProjectSettings.get_setting("pilot_test/phase", 0)
	if phase == 0:
		get_editor_interface().set_plugin_enabled("simple_inventory", true)
		await get_tree().process_frame
		_check(ProjectSettings.has_setting("autoload/ItemManager"), "fresh enable registers manager")
		_check(ProjectSettings.has_setting("autoload/ItemUseStrategyManager"), "fresh enable registers strategies")
		ProjectSettings.set_setting("pilot_test/phase", 1)
	else:
		_check(ProjectSettings.has_setting("autoload/ItemManager"), "restart preserves runtime dependency")
		get_editor_interface().set_plugin_enabled("simple_inventory", false)
		await get_tree().process_frame
		_check(not ProjectSettings.has_setting("autoload/ItemManager"), "disable removes owned manager")
		_check(not ProjectSettings.has_setting("autoload/ItemUseStrategyManager"), "disable removes owned strategies")
		add_autoload_singleton("ItemManager", "res://addons/pilot_test/host_manager.gd")
		var host_autoload: String = ProjectSettings.get_setting("autoload/ItemManager")
		get_editor_interface().set_plugin_enabled("simple_inventory", true)
		await get_tree().process_frame
		_check(ProjectSettings.get_setting("autoload/ItemManager") == host_autoload, "enable preserves conflicting host singleton")
		get_editor_interface().set_plugin_enabled("simple_inventory", false)
		await get_tree().process_frame
		_check(ProjectSettings.get_setting("autoload/ItemManager") == host_autoload, "disable preserves host singleton")
		_check(not ProjectSettings.has_setting("autoload/ItemUseStrategyManager"), "disable removes only owned singleton")
	ProjectSettings.save()
	print("EDITOR LIFECYCLE phase=%d failures=%d" % [phase, _failures])
	get_tree().quit(0 if _failures == 0 else 1)

func _check(condition: bool, message: String) -> void:
	print("LIFECYCLE ", "PASS " if condition else "FAIL ", message)
	if not condition:
		_failures += 1
