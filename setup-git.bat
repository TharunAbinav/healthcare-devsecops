@echo off
cd /d "%~dp0"
git init
git branch -M main
git add .
git commit -m "Initial commit"
echo.
echo Use this folder path as the Repository URL in Jenkins:
echo %~dp0
pause
