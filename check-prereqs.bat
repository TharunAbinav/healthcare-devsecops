@echo off
echo [Git]     & git --version
echo [Docker]  & docker --version
echo [kubectl] & kubectl version --client
echo [curl]    & curl --version
echo [Cluster] & kubectl get nodes
echo.
echo All must work. Docker Desktop needs at least 4 GB RAM (Settings - Resources).
pause
