# Security controls in this project

Demo only, using synthetic data. Using these tools does not by itself make a system HIPAA compliant.

| Healthcare security need | Control in this project | Where |
|---|---|---|
| Keep credentials out of code | Gitleaks secret scan; API key lives only in a Kubernetes Secret | Jenkins stage 1, setup-cluster.bat |
| Secure coding | Semgrep SAST (OWASP Top 10 rules) | Stage 4 |
| Vulnerable libraries | npm audit (SCA), lockfile + npm ci | Stage 3, Dockerfile |
| Secure containers | Multi-stage build, non-root, no npm in runtime image, Hadolint | Dockerfile, stage 2 |
| Image vulnerabilities | Trivy scan with severity gate | Stage 6 |
| Supply-chain visibility | SBOM (CycloneDX) archived every build | Stage 6 |
| Secure infrastructure as code | Trivy config scan of K8s YAML | Stage 7 |
| Least privilege | Dedicated ServiceAccount with no token, drop ALL capabilities, read-only filesystem | k8s/ |
| Cluster-enforced policy | Pod Security "restricted" on the namespace | k8s/00-namespace.yaml |
| Network segmentation | Default-deny NetworkPolicy + allow only port 3000 | k8s/40-networkpolicy.yaml |
| Access control | API key (constant-time compare), 401 for anonymous users | app.js |
| Data minimisation | List endpoint returns masked names, no diagnoses | app.js |
| Audit trail | JSON audit log with no patient data | app.js |
| Abuse protection | Rate limiting, input validation, security headers (helmet) | app.js |
| Runtime testing | OWASP ZAP baseline scan (DAST) + automated "must return 401" test | Stages 10-11 |

## Not covered here (needed in production)
- TLS/HTTPS everywhere (ingress + certificates) and encryption at rest
- Real identity (OIDC/SSO) with roles instead of one shared API key
- Central log storage, alerting, retention policies
- A private image registry with image signing (e.g. cosign)
- Backups, disaster recovery, formal risk assessment and legal review
