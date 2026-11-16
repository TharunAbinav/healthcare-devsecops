@echo off
REM Uses Java 21 explicitly. Edit the path below if your JDK folder is different.
set "PATH=C:\Users\weban\AppData\Local\Programs\Eclipse Adoptium\jdk-21.0.13.9-hotspot\bin;%PATH%"
set JENKINS_WAR=%~dp0jenkins.war
if not exist "%JENKINS_WAR%" (
  echo jenkins.war not found next to this script.
  echo Copy it here or download: https://get.jenkins.io/war-stable/latest/jenkins.war
  pause
  exit /b 1
)
echo Starting Jenkins on http://localhost:9090 ...
java -Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true -jar "%JENKINS_WAR%" --httpPort=9090
