@echo off
echo Audit log (who/what/when/result - no patient data):
kubectl -n healthcare logs -l app=healthcare-api --tail=30
pause
