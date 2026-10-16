# Web 导出

编辑器：`D:\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`

导出模板：`%APPDATA%\Godot\export_templates\4.7.2.stable`，版本必须是 `4.7.2.stable`。线程关闭，使用其中的 `web_nothreads_release.zip`。

先建好输出目录，再在工程根目录导出。Godot 不会自己创建这个目录：

```text
Godot_v4.7.2-stable_win64_console.exe --headless --path H:\godot-projects\y-game --export-release Web H:\godot-projects\y-game\build\web\index.html
```

用静态服务器打开 `build/web`，不要直接双击 `index.html`。例如：

```text
python -m http.server 8060 --bind 127.0.0.1
```

然后访问 `http://127.0.0.1:8060/`。页面会铺满电脑窗口和手机浏览器窗口。

Windows 上的 `python -m http.server` 可能把 `.js` 标成错误的 MIME 类型，浏览器会拒绝加载音频 worklet。游戏画面仍然能启动。要听声音时，换一个会把 `.js` 标成 `application/javascript` 的静态服务器。
