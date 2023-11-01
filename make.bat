@echo off
cd /d "%~dp0"
call shell a
call gfx\makesprites
cd /d "%~dp0"
asm6 -l xex.s 800bros.xex 800bros.lst