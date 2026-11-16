@echo off
cd /d "%~dp0"
echo Trying to deploy a PRIVILEGED root pod into the healthcare namespace...
echo (Expected: Kubernetes REJECTS it because of Pod Security "restricted")
echo.
kubectl apply -f demo\insecure-pod.yaml
echo.
pause
