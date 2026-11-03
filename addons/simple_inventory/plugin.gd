@tool
extends EditorPlugin

const AUTOLOADS: Dictionary[StringName, String] = {
	&"ItemManager": "res://addons/simple_inventory/scripts/managers/item_manager.gd",
	&"ItemUseStrategyManager": "res://addons/simple_inventory/scripts/managers/item_use_strategy_manager.gd",
}
const OWNED_SETTING: String = "simple_inventory/managed_autoloads"

func _enter_tree() -> void:
	var managed: Array = ProjectSettings.get_setting(OWNED_SETTING, [])
	var created: bool = false
	for name: StringName in AUTOLOADS:
		var key: String = "autoload/" + str(name)
		if ProjectSettings.has_setting(key):
			if not _matches_path(ProjectSettings.get_setting(key), AUTOLOADS[name]):
				push_warning("Simple Inventory: 同名单例已存在，未覆盖: " + str(name))
			continue
		# 两个全局管理器互相引用，先保存配置，重启后由引擎统一加载。
		ProjectSettings.set_setting(key, "*" + AUTOLOADS[name])
		created = true
		if not managed.has(str(name)):
			managed.append(str(name))
	if not managed.is_empty():
		ProjectSettings.set_setting(OWNED_SETTING, managed)
		ProjectSettings.save()
	if created:
		print("Simple Inventory: 单例配置已保存，请重启 Godot 完成启用。")

## 仅实际禁用时移除自己创建的单例；关闭编辑器不卸载运行依赖。
func _disable_plugin() -> void:
	var managed: Array = ProjectSettings.get_setting(OWNED_SETTING, [])
	for raw_name: Variant in managed:
		var name: StringName = StringName(str(raw_name))
		if AUTOLOADS.has(name) and _matches_path(ProjectSettings.get_setting("autoload/" + str(name), ""), AUTOLOADS[name]):
			remove_autoload_singleton(name)
	if ProjectSettings.has_setting(OWNED_SETTING):
		ProjectSettings.clear(OWNED_SETTING)
	ProjectSettings.save()

func _matches_path(raw: Variant, expected: String) -> bool:
	var entry: String = str(raw)
	if not entry.begins_with("*"):
		return false
	var path: String = entry.trim_prefix("*")
	if path.begins_with("uid://"):
		var id: int = ResourceUID.text_to_id(path)
		return ResourceUID.has_id(id) and ResourceUID.get_id_path(id) == expected
	return path == expected
