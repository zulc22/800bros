@echo off
cd /d "%~dp0"
set path=%path%;%~dp0\winbin
if "%~1"=="" cmd