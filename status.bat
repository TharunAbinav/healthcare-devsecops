@echo off
kubectl -n healthcare get deployments,pods,svc,networkpolicy
pause
