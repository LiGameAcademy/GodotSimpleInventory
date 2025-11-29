extends Resource
class_name GameplayEquipType

## 装备类型配置

## 装备类型唯一标识符
@export var type_id: StringName = ""

## 显示名称
@export var display_name: String = ""

## 图标（可选）
@export var icon: Texture2D = null

## 是否允许多个（如戒指）
@export var allow_multiple: bool = false

## 排序优先级（用于UI显示）
@export var sort_order: int = 0

func _init(
        p_type_id: StringName = "",
        p_display_name: String = "",
        p_icon: Texture2D = null,
        p_allow_multiple: bool = false,
        p_sort_order: int = 0
        ) -> void:
    type_id = p_type_id
    display_name = p_display_name
    icon = p_icon
    allow_multiple = p_allow_multiple
    sort_order = p_sort_order

func compare_to(other: GameplayEquipType) -> bool:
    return sort_order < other.sort_order