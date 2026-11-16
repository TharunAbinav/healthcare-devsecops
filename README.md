# DevSecOps for a Healthcare API (Jenkins + Docker + Kubernetes, Windows)

Pipeline: Secrets -> Dockerfile lint -> Dependencies -> SAST -> Build -> Image scan + SBOM -> K8s manifest scan -> Deploy -> Security tests -> DAST

App URL: http://localhost:30100   (patient endpoints need the x-api-key header)

Setup order
1. Docker Desktop running with Kubernetes (Kubeadm), at least 4 GB RAM.
2. check-prereqs.bat
3. setup-git.bat
4. Start Jenkins (start-jenkins.bat, needs jenkins.war here) or reuse your running Jenkins.
5. setup-cluster.bat  (creates the namespace and the secret ONE time)
6. Jenkins: New Item -> healthcare-devsecops -> Pipeline -> Pipeline script from SCM
   Git, Repository URL = this folder (forward slashes), Branch */main, Script Path Jenkinsfile
7. Build Now (first run downloads several GB of scanner images: be patient)
8. test-api.bat

Demos: demo-leak-secret.bat, demo-vulnerable-code.bat, demo-block-insecure-pod.bat, demo-reset.bat
Docs: docs\security-controls.md
