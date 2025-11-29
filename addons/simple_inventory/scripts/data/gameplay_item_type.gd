extends Resource
class_name GameplayItemType

## 物品类型唯一标识符
@export var type_id: StringName = ""

## 显示名称
@export var display_name: String = ""

## 图标（可选）
@export var icon: Texture2D = null

## 排序优先级（用于UI显示）
@export var sort_order: int = 0

## 是否可堆叠
@export var stackable: bool = true

## 默认最大堆叠数
@export var default_max_stack: int = 1

## 使用策略ID（用于物品使用，如 "equip", "consumable"）
@export var use_strategy_id: StringName = ""

func _init(
        p_type_id: StringName = "",
        p_display_name: String = "",
        p_icon: Texture2D = null,
        p_sort_order: int = 0,
        p_stackable: bool = true,
        p_default_max_stack: int = 1,
        p_use_strategy_id: StringName = ""
        ) -> void:
    type_id = p_type_id
    display_name = p_display_name
    icon = p_icon
    sort_order = p_sort_order
    stackable = p_stackable
    default_max_stack = p_default_max_stack
    use_strategy_id = p_use_strategy_id

func compare_to(other: GameplayItemType) -> bool:
    return sort_order < other.sort_order