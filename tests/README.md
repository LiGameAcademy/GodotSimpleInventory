# 单元测试

本目录包含背包系统的单元测试脚本。

## 测试结构

```
tests/
├── test_runner.gd              # 测试运行器（基础类）
├── test_main.gd                # 测试主入口
├── test_main.tscn              # 测试场景
├── test_gameplay_item_instance.gd  # GameplayItemInstance 测试
├── test_item_manager.gd        # ItemManager 测试
├── test_inventory_component.gd # InventoryComponent 测试
├── test_item_merger.gd         # ItemMerger 测试
├── test_inventory_sorter.gd    # InventorySorter 测试
└── test_equipment_component.gd  # EquipmentComponent 测试
```

## 运行测试

### 方法1：在Godot编辑器中运行

1. 打开 `tests/test_main.tscn` 场景
2. 运行当前场景（F6）
3. 查看输出面板中的测试结果

### 方法2：通过命令行运行

```bash
godot --headless --editor --path . --import
godot --headless --path . res://tests/test_main.tscn
godot --headless --path . res://tests/test_ui_isolation.tscn
```

## 测试覆盖

当前核心入口包含9个套件、169项断言；双UI场景另含10项断言。新增InventoryReceipts覆盖完整堆叠入包、原始接收数量、拒绝无通知和恢复不计入；插件目录另含9项空宿主契约。统一命令为python tools/run_checks.py --godot <Godot路径>。
核心测试覆盖部分堆叠数量守恒、尾槽缩容、原子添加及通知、满背包换装、独占实例和JSON快照恢复。UI场景覆盖隐藏面板、A/B隔离和重绑。

命令行成功退出码为0，断言失败为1。使用 `res://tests/test_main.tscn -- --verify-failure` 可验证失败退出码；该参数刻意产生一项失败，不用于正常验收。
运行检查还必须查看脚本解析错误及测试完成标记，不能只看进程退出码。

Windows编辑器生命周期验证（会在系统临时目录创建独立工程并保留日志）：

```powershell
./tools/verify_editor_lifecycle.ps1 -Godot '绝对路径/Godot_console.exe'
```

包含首次安装、重启、禁用与宿主同名单例保护，共8项检查；不在当前编辑器工程中切换插件。

### GameplayItemInstance
- ✅ 实例创建
- ✅ 堆叠上限检查
- ✅ 物品合并
- ✅ 数量设置和验证
- ✅ 无效配置处理

### ItemManager
- ✅ 物品配置注册和获取
- ✅ 物品类型注册和获取
- ✅ 装备类型注册和获取
- ✅ 物品实例创建
- ✅ 装备实例创建
- ✅ 无效ID处理

### InventoryComponent
- ✅ 添加物品
- ✅ 物品堆叠
- ✅ 获取物品
- ✅ 移除物品
- ✅ 空槽位查找
- ✅ 背包满时处理
- ✅ 通过ID添加/移除物品

### ItemMerger
- ✅ 合并相同物品
- ✅ 不同物品不合并
- ✅ 空数组处理
- ✅ 包含null的数组处理

### InventorySorter
- ✅ 按类型排序
- ✅ 按名称排序
- ✅ 空数组处理
- ✅ 包含null的数组处理

### EquipmentComponent
- ✅ 槽位初始化
- ✅ 装备物品
- ✅ 卸载装备
- ✅ 多槽位装备（如戒指）
- ✅ 无效槽位处理

## 添加新测试

1. 创建新的测试文件，继承 `TestRunner`
2. 实现测试方法，使用断言函数
3. 在 `test_runner.gd` 的 `run_all_tests()` 中添加测试套件

示例：

```gdscript
extends TestRunner
class_name TestMyClass

func test_my_class() -> void:
    print("  测试 MyClass...")
    
    # 你的测试代码
    assert_true(true, "测试应该通过")
    
    print("  ✓ MyClass 测试完成")
```

## 断言函数

- `assert_true(condition, message)` - 断言为真
- `assert_false(condition, message)` - 断言为假
- `assert_equal(actual, expected, message)` - 断言相等
- `assert_not_equal(actual, expected, message)` - 断言不相等
- `assert_null(value, message)` - 断言为null
- `assert_not_null(value, message)` - 断言不为null
- `assert_greater_than(actual, expected, message)` - 断言大于
- `assert_less_than(actual, expected, message)` - 断言小于

## 注意事项

1. 测试需要确保 `ItemManager` 和 `ItemUseStrategyManager` 已作为 AutoLoad 单例初始化
2. 某些测试可能需要创建临时场景节点
3. 测试完成后记得清理资源（使用 `queue_free()`）

