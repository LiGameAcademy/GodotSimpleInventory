extends Resource
class_name GameplayEquipType

## 装备类型配置

## 装备类型唯一标识符
@export var type_id: StringName = ""

## 显示名称
@export var display_name: String = ""

## 图标（可选）
@export var icon: Texture2D = null

## 槽位纹理（可选）
@export var slot_texture: Texture2D = null

## 是否允许多个（如戒指）
@export var allow_multiple: bool = false

## 排序优先级（用于UI显示）
@export var sort_order: int = 0
