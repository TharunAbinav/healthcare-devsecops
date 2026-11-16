@echo off
cd /d "%~dp0"
git rm -f --ignore-unmatch leaked.env bad-routes.js
git commit -m "Remove demo files" 
echo.
echo Removed. NOTE: a real leaked secret would still live in git history - always ROTATE leaked secrets.
pause
