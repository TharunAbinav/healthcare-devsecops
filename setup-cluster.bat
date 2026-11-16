@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
echo === Creating hardened namespace (Pod Security: restricted) ===
kubectl apply -f k8s\00-namespace.yaml

kubectl -n healthcare get secret healthcare-secrets >nul 2>&1
if %errorlevel%==0 (
  echo Secret already exists - keeping the existing API key.
) else (
  for /f "delims=" %%k in ('powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\gen-key.ps1"') do set API_KEY=%%k
  kubectl -n healthcare create secret generic healthcare-secrets --from-literal=API_KEY=!API_KEY!
  echo !API_KEY!> "%USERPROFILE%\healthcare-api-key.txt"
  echo.
  echo Random API key created and stored ONLY in the cluster Secret.
  echo A copy for you to test with was saved OUTSIDE the repo:
  echo   %USERPROFILE%\healthcare-api-key.txt
)
echo.
echo Done. Now run the Jenkins pipeline.
pause
