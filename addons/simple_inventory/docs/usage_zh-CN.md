# 安装与使用

当前实测 Godot 4.7.2，未验证 4.5。本仓库根目录就是插件，应放到宿主 addons/simple_inventory；不要把包含示例工程的整个源仓库放到该目录。

```sh
git submodule add https://github.com/LiGameAcademy/laoli_simple_inventory.git addons/simple_inventory
git -C addons/simple_inventory checkout <已验证标签或提交>
```

宿主提交 .gitmodules 和固定版本指针；其他人递归克隆，或运行 git submodule update --init --recursive。也支持复制完整插件目录。

在项目设置启用 li_simple_inventory 后重启编辑器，让 ItemManager 与 ItemUseStrategyManager 共同加载。插件保留既有同名单例；不同实现需先解决冲突。

配置 InventoryComponent、EquipmentComponent 及装备槽，将组件和使用者显式传给 InventoryPanel.initialize_components()。规则可以脱离UI使用。配置Resource按只读使用；运行物品实例独占容器。

宿主向 ItemManager 注册物品配置，再调用 inventory.add_item()。返回false不会部分修改传入物品或背包。成功后 items_received(item_id: StringName, quantity: int) 只发送一次原始接收数量，即使全部合并到已有堆叠。收集目标可监听该事件；item_added只表示新槽位，不能覆盖完整堆叠。经add_item转交物品也会通知，宿主决定哪些来源计入任务。

InventorySnapshot.capture()生成版本1数据，可经JSON保存；restore()前先注册物品和装备槽配置。恢复先验证两容器，再统一刷新，不发送入包事件。治疗、角色属性、技能、模型、磁盘读写和完整游戏存档政策均由宿主负责。

python tools/run_tests.py --godot <Godot路径> 在隔离空工程中验证安装与基础契约；源工程另有完整规则、双UI隔离及编辑器生命周期验证。
