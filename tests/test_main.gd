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
	if "--verify-failure" in OS.get_cmdline_user_args():
		test_runner.assert_true(false, "验证失败时必须返回非零退出码")
	var exit_code: int = 0 if test_runner.failed_tests == 0 else 1
	test_runner.free()
	# 等待测试创建的临时节点完成释放。
	await get_tree().process_frame
	if DisplayServer.get_name() == "headless" or "--ci" in OS.get_cmdline_user_args():
		get_tree().quit(exit_code)
