@echo off
kubectl delete namespace healthcare --ignore-not-found
del "%USERPROFILE%\healthcare-api-key.txt" 2>nul
echo Cleaned up (namespace, secret and local key file removed).
pause
