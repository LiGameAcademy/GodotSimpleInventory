# 开源试点迁移说明（未发布）

本轮从cd4bf24迁移。实测Godot 4.7.2；原工程声明4.5，尚未验证4.5补丁版本。

## 安装

将完整 `addons/simple_inventory` 复制到宿主工程，启用插件后重启Godot。首次启用先写入两个Autoload配置，重启后由引擎统一加载，避免互相引用的脚本在注册过程中解析失败。

已有同名Autoload不会被覆盖或接管。若指向不同脚本，先解决名称冲突。禁用只移除本插件创建且仍指向本插件的单例；关闭编辑器保留依赖。手动配置的单例由宿主维护。

## 显式接入

在场景中配置InventoryComponent与EquipmentComponent及装备槽资源。父级将组件与使用者传给UI或规则入口：

```gdscript
@onready var inventory: InventoryComponent = $InventoryComponent
@onready var equipment: EquipmentComponent = $EquipmentComponent
@onready var panel: InventoryPanel = $InventoryPanel

func _ready() -> void:
    inventory.initialize(self, equipment)
    panel.initialize_components(inventory, equipment, self)
```

无UI时只初始化规则组件。属性、治疗、技能、模型由宿主的使用策略或装备变更回调实现。
旧 `initialize(entity)` 仅通过公开 `get_inventory_component()` / `get_equipment_component()` 方法解析，不再猜节点名、父节点或全树分组。单独使用InventoryWidget/EquipmentWidget时，由父级连接 `item_use_requested` / `unequip_requested` 并调用规则组件。

## 失败与所有权

- `add_item()` 返回false时传入实例、现有数量和组件通知均不变；成功后才发组件通知。
- 配置资源共享且按只读使用；每个运行实例只能属于一个背包或装备组件。转交前通过原容器移除。
- 部分合并保留余量。相同配置、相同耐久的普通物品可堆叠；装备不堆叠。
- 普通缩容检查真正被截断的尾槽。强制缩容通过 `items_discarded` 返回被移除实例，宿主决定其去向。
- 每个装备槽只持有一个实例。多戒指使用不同slot_id；不再用允许多实例的标记覆盖同一字典项。
- 背包来源换装使用精确来源槽交换，满背包仍可成功；没有来源槽时，旧装备必须有可接收的背包，否则失败。
- 数组/字典保留读取兼容性；直接写 `items` / `equipped_items` 或直接改变已持有实例数量会绕过校验及通知，不属于支持的修改入口。

## 快照

```gdscript
var saved: Dictionary = InventorySnapshot.capture(inventory, equipment)
var restored: bool = InventorySnapshot.restore(saved, inventory, equipment)
```

版本1保存槽位、容量、物品ID、实例ID、数量、耐久、装备强化等级及附魔ID。附魔字段改为 `Array[StringName]`，不持久化任意Resource/Variant。恢复前先注册全部物品配置；装备槽配置仍由宿主场景提供。
未知版本/物品/槽、重复实例ID或无效数量等坏数据返回false，并保留原状态。两容器验证完成后提交、统一通知。磁盘路径、原子写文件、完整角色存档和旧格式升级由宿主负责。

详见核心测试与ARPG宿主切片。代码许可不自动覆盖默认UI素材；素材来源待核验，本轮未生成公开发行包。
