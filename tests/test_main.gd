extends Node
class_name TestMain

## 测试主入口
## 在场景中运行此脚本以执行所有单元测试

@onready var test_runner: TestRunner = TestRunner.new()

func _ready() -> void:
	# 等待一帧，确保所有AutoLoad单例已初始化
	await get_tree().process_frame
	
	# 运行所有测试
	test_runner.run_all_tests()
	
	# 测试完成后退出（可选）
	# get_tree().quit()
