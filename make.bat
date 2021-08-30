@echo off
cd /d "%~dp0"
call shell a
call gfx\makesprites
asm6 -l xex.s 800bros.xex