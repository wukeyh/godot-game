@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
title y-game web

if not exist "build\web\index.html" (
  echo 还没有 build\web\index.html，请先按 docs\web-export.md 导出。
  pause
  exit /b 1
)

where python >nul 2>&1
if errorlevel 1 (
  echo 没有找到 python，无法启动本地服务器。
  pause
  exit /b 1
)

netstat -ano | findstr /C:":8060 " | findstr "LISTENING" >nul
if not errorlevel 1 (
  echo 8060 端口已被占用。请关掉之前的调试窗口后再打开。
  pause
  exit /b 1
)

echo 正在启动 http://127.0.0.1:8060/
start "y-game-open" /min powershell -NoProfile -WindowStyle Hidden -Command "for ($i=0; $i -lt 50; $i++) { try { $client = New-Object System.Net.Sockets.TcpClient; $client.Connect('127.0.0.1', 8060); $client.Close(); Start-Process 'http://127.0.0.1:8060/'; exit 0 } catch { Start-Sleep -Milliseconds 200 } }"

python "%~dp0open-web.py"