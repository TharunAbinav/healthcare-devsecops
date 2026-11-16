@echo off
REM DEMO 2: adds code with SQL injection + XSS. The pipeline should FAIL at stage 4 (Semgrep).
cd /d "%~dp0"
copy /y demo\bad-routes.js.txt bad-routes.js >nul
git add bad-routes.js
git commit -m "DEMO: add vulnerable code"
echo.
echo Now run the Jenkins build. Stage "4. Code Scan - SAST" should FAIL.
echo Undo with demo-reset.bat
pause
