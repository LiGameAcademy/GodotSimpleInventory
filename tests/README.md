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
2. 点击运行按钮（F5）
3. 查看输出面板中的测试结果

### 方法2：通过命令行运行

```bash
godot --path . --script tests/test_main.gd
```

## 测试覆盖

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

