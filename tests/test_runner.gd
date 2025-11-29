extends Node
class_name TestRunner

## 测试运行器
## 用于运行所有单元测试并报告结果

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0
var test_results: Array[Dictionary] = []

## 运行所有测试
func run_all_tests() -> void:
	print("\n========== 开始运行单元测试 ==========\n")
	
	total_tests = 0
	passed_tests = 0
	failed_tests = 0
	test_results.clear()
	
	# 运行所有测试套件
	run_test_suite("GameplayItemInstance", TestGameplayItemInstance.new())
	run_test_suite("ItemManager", TestItemManager.new())
	run_test_suite("InventoryComponent", TestInventoryComponent.new())
	run_test_suite("ItemMerger", TestItemMerger.new())
	run_test_suite("InventorySorter", TestInventorySorter.new())
	run_test_suite("EquipmentComponent", TestEquipmentComponent.new())
	
	# 打印总结
	print("\n========== 测试总结 ==========")
	print("总测试数: %d" % total_tests)
	print("通过: %d" % passed_tests)
	print("失败: %d" % failed_tests)
	print("成功率: %.1f%%" % (float(passed_tests) / float(total_tests) * 100.0 if total_tests > 0 else 0.0))
	
	# 打印失败的测试
	if failed_tests > 0:
		print("\n失败的测试:")
		for result in test_results:
			if not result.success:
				print("  - %s.%s: %s" % [result.suite, result.test, result.message])

## 运行测试套件
func run_test_suite(suite_name: String, test_instance: TestRunner) -> void:
	print("运行测试套件: %s" % suite_name)
	var suite_passed_before: int = passed_tests
	var suite_failed_before: int = failed_tests
	
	# 将当前运行器的状态传递给测试实例
	test_instance.total_tests = total_tests
	test_instance.passed_tests = passed_tests
	test_instance.failed_tests = failed_tests
	test_instance.test_results = test_results
	
	# 运行测试方法（根据套件名称调用对应方法）
	var method_name: String = ""
	match suite_name:
		"GameplayItemInstance":
			method_name = "test_gameplay_item_instance"
		"ItemManager":
			method_name = "test_item_manager"
		"InventoryComponent":
			method_name = "test_inventory_component"
		"ItemMerger":
			method_name = "test_item_merger"
		"InventorySorter":
			method_name = "test_inventory_sorter"
		"EquipmentComponent":
			method_name = "test_equipment_component"
	
	if not method_name.is_empty() and test_instance.has_method(method_name):
		test_instance.call(method_name)
	else:
		push_error("测试套件 %s 未找到测试方法 %s" % [suite_name, method_name])
	
	# 同步状态
	total_tests = test_instance.total_tests
	passed_tests = test_instance.passed_tests
	failed_tests = test_instance.failed_tests
	test_results = test_instance.test_results
	
	var suite_passed: int = passed_tests - suite_passed_before
	var suite_failed: int = failed_tests - suite_failed_before
	print("  %s: 通过 %d, 失败 %d\n" % [suite_name, suite_passed, suite_failed])

## 断言函数
func assert_true(condition: bool, message: String = "") -> bool:
	total_tests += 1
	if condition:
		passed_tests += 1
		return true
	else:
		failed_tests += 1
		var error_msg: String = message if not message.is_empty() else "断言失败: 期望为 true"
		push_error("测试失败: " + error_msg)
		return false

func assert_false(condition: bool, message: String = "") -> bool:
	return assert_true(not condition, message if not message.is_empty() else "断言失败: 期望为 false")

func assert_equal(actual: Variant, expected: Variant, message: String = "") -> bool:
	var condition: bool = actual == expected
	var error_msg: String = message if not message.is_empty() else "期望 %s, 实际 %s" % [str(expected), str(actual)]
	return assert_true(condition, error_msg)

func assert_not_equal(actual: Variant, expected: Variant, message: String = "") -> bool:
	var condition: bool = actual != expected
	var error_msg: String = message if not message.is_empty() else "期望不等于 %s, 实际 %s" % [str(expected), str(actual)]
	return assert_true(condition, error_msg)

func assert_null(value: Variant, message: String = "") -> bool:
	var condition: bool = value == null
	var error_msg: String = message if not message.is_empty() else "期望为 null, 实际 %s" % str(value)
	return assert_true(condition, error_msg)

func assert_not_null(value: Variant, message: String = "") -> bool:
	var condition: bool = value != null
	var error_msg: String = message if not message.is_empty() else "期望不为 null, 实际为 null"
	return assert_true(condition, error_msg)

func assert_greater_than(actual: Variant, expected: Variant, message: String = "") -> bool:
	var condition: bool = actual > expected
	var error_msg: String = message if not message.is_empty() else "期望 %s > %s" % [str(actual), str(expected)]
	return assert_true(condition, error_msg)

func assert_less_than(actual: Variant, expected: Variant, message: String = "") -> bool:
	var condition: bool = actual < expected
	var error_msg: String = message if not message.is_empty() else "期望 %s < %s" % [str(actual), str(expected)]
	return assert_true(condition, error_msg)

## 测试套件方法（由子类实现）
## 这些方法在子类中被重写
