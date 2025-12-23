@echo off
chcp 65001 > nul  
setlocal EnableDelayedExpansion

set "NIRCMD=nircmd.exe"

:: 媒体播放器的进程名
set "PLAYER_PROCESS=Microsoft.Media.Player.exe"

:: 检查 nircmd.exe 是否存在
if not exist "%NIRCMD%" (
    echo [ERROR] nircmd.exe not found! 请确保它和本脚本在同一目录。
    pause
    exit /b 1
)

:: 1. 播放新歌曲（参数是文件路径）
if "%~1" neq "" if /i "%~1" neq "pause" if /i "%~1" neq "quit" (
    echo [PLAY] 正在播放: %~1
    :: 先关闭所有新版 Media Player 窗口，防止多开
    %NIRCMD% win close title "Media Player"
    :: 短暂延迟，确保关闭完成
    ping 127.0.0.1 -n 2 -w 500 >nul
    :: 用系统默认方式启动文件（会打开新版 Media Player）
    start "" "%~1"
    exit /b
)

:: 2. 暂停/继续
if /i "%~1"=="pause" (
    echo [PAUSE/RESUME] 切换暂停/继续（全局媒体键）...
    %NIRCMD% sendkeypress 0xB3
    exit /b
)


:: 3. 退出播放器
if /i "%~1"=="quit" (
    echo [QUIT] 正在关闭 Media Player...
    %NIRCMD% win close title "Media Player"
    :: 额外强制杀进程（新版 Media Player 的可执行文件在 WindowsApps 目录）
    taskkill /f /im "Microsoft.Media.Player.exe" >nul 2>&1
    taskkill /f /im "ZuneMusic.exe" >nul 2>&1  :: 旧包名兼容
    exit /b
)

:: 默认提示
echo [INFO] 用法:
echo   播放:   host_play.bat "MUSIC\SONG01.MP3"
echo   暂停:   host_play.bat pause
echo   退出:   host_play.bat quit
exit /b