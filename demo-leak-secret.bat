@echo off
REM DEMO 1: simulates a developer accidentally committing a token. The pipeline must FAIL at stage 1.
cd /d "%~dp0"
set P1=ghp_R7kP2mXq9LdVw4
set P2=TnB8sYc3HzJf6UaE1oN5gQ
echo GITHUB_TOKEN=%P1%%P2%> leaked.env
git add leaked.env
git commit -m "DEMO: accidentally commit a secret"
echo.
echo Now run the Jenkins build. Stage "1. Secret Scan" should FAIL.
echo Undo with demo-reset.bat
pause
