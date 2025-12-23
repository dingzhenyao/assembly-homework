@echo off
title Music Control Monitor
echo Music monitor is running in background...
echo Press =1~7 to play, =9 to pause/resume, =0 to quit

:loop
if exist player.bat (
    call player.bat
    del player.bat >nul 2>&1
)

if exist pause.bat (
    call host_play.bat pause
    del pause.bat >nul 2>&1
)

if exist quit.bat (
    call host_play.bat quit
    del quit.bat >nul 2>&1
    echo Music monitor stopped.
    exit
)

rem 减少CPU占用，暂停0.2秒
ping 127.0.0.1 -n 1 -w 200 >nul 2>&1

goto loop