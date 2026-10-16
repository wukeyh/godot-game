# Web 导出

编辑器：`D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`

导出模板：`%APPDATA%\Godot\export_templates\4.7.2.stable`，版本必须是 `4.7.2.stable`。线程关闭，使用其中的 `web_nothreads_release.zip`。

先建好输出目录，再在工程根目录导出。Godot 不会自己创建这个目录：

```text
Godot_v4.7.2-stable_win64_console.exe --headless --path H:\godot-projects\y-game --export-release Web H:\godot-projects\y-game\build\web\index.html
```

调试时双击工程根目录的 `open-web.bat`。它会在 `127.0.0.1:8060` 打开已经导出的 `build/web`，并启动浏览器。不要直接双击 `index.html`。关掉这个窗口或按 Ctrl+C 即停止服务。

页面会铺满电脑窗口和手机浏览器窗口。
