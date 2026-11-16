@echo off
setlocal
set /p KEY=<"%USERPROFILE%\healthcare-api-key.txt"
echo === 1. No API key (expect 401) ===
curl -s -o NUL -w "HTTP %%{http_code}\n" http://localhost:30100/api/patients
echo.
echo === 2. Wrong API key (expect 401) ===
curl -s -o NUL -w "HTTP %%{http_code}\n" -H "x-api-key: wrong" http://localhost:30100/api/patients
echo.
echo === 3. Valid key: masked patient list ===
curl -s -H "x-api-key: %KEY%" http://localhost:30100/api/patients
echo.
echo.
echo === 4. Valid key: one full record ===
curl -s -H "x-api-key: %KEY%" http://localhost:30100/api/patients/1
echo.
echo.
echo === 5. Malformed id (expect 400) ===
curl -s -o NUL -w "HTTP %%{http_code}\n" -H "x-api-key: %KEY%" http://localhost:30100/api/patients/abc
echo.
echo === 6. Security headers ===
curl -sI http://localhost:30100/health | findstr /i "content-security strict-transport x-content-type"
pause
