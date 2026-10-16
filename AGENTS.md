# y-game

给后续 AI 的入口。先读本文件，再按任务打开对应文档或脚本。不要通读整个仓库。

这是 Godot 4.7 工程，渲染器是 `gl_compatibility`。同一份 Web 包要在电脑浏览器和手机浏览器里铺满窗口。主场景是 `res://scenes/boot.tscn`。

## 目录

| 路径 | 职责 |
| --- | --- |
| `scenes/` | 场景。只服务一个场景的脚本放在该场景旁边 |
| `scripts/framework/ui/` | 页面和控件基类：`UIWidget`、`UIPage`、`UIPageManager` |
| `scripts/framework/event/` | 模块间事件：`EventSystem`、`EventDispatcher`、`EventListener`、`EventDefine` |
| `scripts/` | 多个场景共用、又不属于 framework 的脚本。按功能再分子目录，不按文件类型分 |
| `resources/` | `.tres` 数据 |
| `assets/` | 共享图、音频、字体 |
| `export/` | Web 页面壳 |
| `docs/` | 给人读的操作说明。Godot 不导入这个目录 |

业务页面不要放进 `scripts/framework/ui/`。那个目录只放可复用的页面框架。

## 运行与导出

调试时双击工程根目录的 `open-web.bat`。它会打开 `http://127.0.0.1:8060/`。不要双击 `build/web/index.html`，浏览器会报 `Failed to fetch`。导出步骤见 `docs/web-export.md`。`build/` 不进 Git。

## 框架约定

- 需要操作结果时直接调用管理器。已有明确对象引用的变化用 Godot signal。独立模块之间广播已经发生的事实时，用 `EventSystem.get_instance().dispatcher`。
- 事件入口是普通 `RefCounted` 单例，不注册成 AutoLoad。监听使用 `add_event_listener`，取消使用返回的 `EventListener.cancel()`。回调必须是单参数的普通对象方法。
- 页面生命周期由 `UIPageManager` 管理。`open()` / `close()` 负责显示、隐藏和调用 `on_open()` / `on_close()`。子类扩展这些钩子时要调用 `super`。
- 源码使用 UTF-8。GDScript 缩进用 Tab。
