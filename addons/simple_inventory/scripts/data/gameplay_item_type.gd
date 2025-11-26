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
