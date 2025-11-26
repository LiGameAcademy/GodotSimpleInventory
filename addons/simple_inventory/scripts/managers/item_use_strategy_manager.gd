extends Node

## 道具使用策略管理器

## 策略字典（strategy_id -> 策略类）
## 注意：存储的是类引用（GDScript），而不是实例
## 每次调用 get_strategy() 时创建新实例，确保策略无状态
var strategies: Dictionary[StringName, GDScript] = {}

func _ready() -> void:
	# 注册默认策略
	register_strategy("equip", EquipUseStrategy)
	register_strategy("consumable", ConsumableUseStrategy)

## 注册策略
## strategy_class: 策略类（如 EquipUseStrategy），必须是 ItemUseStrategy 的子类
## 
## 为什么传入类而不是实例？
## 1. 策略应该是无状态的，每次使用都需要创建新实例
## 2. 如果传入实例，所有使用该策略的地方都会共享同一个实例，可能导致状态污染
## 3. 传入类引用更灵活，可以在创建时传递参数（如果需要）
func register_strategy(strategy_id: StringName, strategy_class: GDScript) -> void:
	if not strategy_class:
		push_error("ItemUseStrategyManager: 策略类无效")
		return
	
	# 验证是否为 ItemUseStrategy 的子类
	var test_instance = strategy_class.new()
	if not test_instance is ItemUseStrategy:
		push_error("ItemUseStrategyManager: 策略类必须是 ItemUseStrategy 的子类")
		if test_instance is RefCounted:
			test_instance = null
		return
	
	if test_instance is RefCounted:
		test_instance = null
	
	if strategies.has(strategy_id):
		push_warning("ItemUseStrategyManager: 策略ID已存在: " + str(strategy_id) + "，将覆盖")
	strategies[strategy_id] = strategy_class

## 通过ID获取策略实例
## 注意：每次调用都创建新实例，确保策略无状态
func get_strategy(strategy_id: StringName) -> ItemUseStrategy:
	var strategy_class: GDScript = strategies.get(strategy_id)
	if not strategy_class:
		push_error("ItemUseStrategyManager: 未找到策略: " + str(strategy_id))
		return null
	
	var instance = strategy_class.new()
	if not instance is ItemUseStrategy:
		push_error("ItemUseStrategyManager: 策略类实例化失败")
		return null
	
	return instance as ItemUseStrategy
