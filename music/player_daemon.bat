@echo off
:loop
if exist music\player.bat (
  rem 当检测到 player.bat 时执行它（应包含对 player.exe 的调用）
  player.bat
  del music\player.bat
)
goto loop
