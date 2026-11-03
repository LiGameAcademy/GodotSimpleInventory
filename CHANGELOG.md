# Changelog

## 0.0.2 — 插件发行收口

- 完整堆叠入包发items_received；失败和快照恢复不发，增加独立回归。
- 从addons/simple_inventory生成插件根目录发行库，保留本仓库作为权威源码、教学与完整测试宿主。
- 默认UI改用确认来源的Cryo区域，补Shikashi与Adobe署名和OFL，移除未确认旧GUI与闲置音效。
- 当前规则169项、双UI隔离10项、空宿主9项；具体运行记录见本次PR。支持基线Godot4.7.2。

## Unreleased — 开源试点

- 修复部分堆叠余量丢失、稀疏缩容检查和添加失败时的部分修改。
- 加入实例容器归属；修复换装失败丢旧装备、满背包来源槽交换及重复实例接收。
- UI使用/卸装意图向上发信号；支持双面板、隐藏槽和重新绑定。
- 增加版本1 JSON快照，坏数据不覆盖状态。
- 插件首次启用保存单例配置并要求重启；禁用保护既有同名单例。
- 修正命令行测试入口及失败退出码；新增安全、快照、UI隔离测试。

迁移约束见 [pilot_migration.md](addons/simple_inventory/docs/pilot_migration.md)。尚未发布、打tag或声明Godot 4.5实测兼容。
