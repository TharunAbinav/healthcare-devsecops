pipeline {
    agent any

    parameters {
        choice(name: 'SEVERITY_GATE', choices: ['CRITICAL', 'HIGH,CRITICAL'],
               description: 'Fail the build if the image scan finds FIXABLE vulnerabilities at this level')
        booleanParam(name: 'RUN_DAST', defaultValue: true,
                     description: 'Run an OWASP ZAP scan against the deployed app')
    }

    environment {
        IMAGE_NAME = 'healthcare-api'
        IMAGE_TAG  = "${BUILD_NUMBER}"
        NAMESPACE  = 'healthcare'
        APP_URL    = 'http://localhost:30100'
    }

    stages {

        stage('Checkout') {
            steps {
                deleteDir()          // clean workspace so old reports/tar files are never scanned
                checkout scm
            }
        }

        stage('Check Tools') {
            steps {
                bat 'docker --version'
                bat 'kubectl version --client'
                bat 'kubectl get nodes'
            }
        }

        // ---------- SHIFT-LEFT SECURITY (before anything is built) ----------

        stage('1. Secret Scan (Gitleaks)') {
            steps {
                bat 'docker run --rm -v "%CD%:/repo" zricethezav/gitleaks:latest detect --no-git --source /repo --redact --no-banner --exit-code 1'
            }
        }

        stage('2. Dockerfile Lint (Hadolint)') {
            steps {
                bat 'docker run --rm -i hadolint/hadolint hadolint --failure-threshold warning - < Dockerfile'
            }
        }

        stage('3. Dependency Scan - SCA (npm audit)') {
            steps {
                bat 'docker run --rm -v "%CD%:/app" -w /app node:24-alpine npm audit --audit-level=high'
            }
        }

        stage('4. Code Scan - SAST (Semgrep)') {
            steps {
                bat 'docker run --rm -v "%CD%:/src" semgrep/semgrep semgrep scan --config p/javascript --config p/nodejs --config p/owasp-top-ten --severity ERROR --error --metrics=off --exclude node_modules --exclude demo /src'
            }
        }

        // ---------- BUILD + SCAN THE ARTIFACT ----------

        stage('5. Build Docker Image') {
            steps {
                bat "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('6. Image Scan + SBOM (Trivy)') {
            steps {
                bat "docker save -o image.tar ${IMAGE_NAME}:${IMAGE_TAG}"
                // Report (never fails): everything HIGH and above, so you can read it
                bat 'docker run --rm -v trivy-cache:/root/.cache/ -v "%CD%:/work" aquasec/trivy:latest image --input /work/image.tar --severity HIGH,CRITICAL --ignore-unfixed --no-progress'
                // SBOM (software bill of materials) for supply-chain tracking
                bat 'docker run --rm -v trivy-cache:/root/.cache/ -v "%CD%:/work" aquasec/trivy:latest image --input /work/image.tar --format cyclonedx --output /work/sbom.cdx.json --no-progress'
                // Gate: fails the build
                bat "docker run --rm -v trivy-cache:/root/.cache/ -v \"%CD%:/work\" aquasec/trivy:latest image --input /work/image.tar --severity ${params.SEVERITY_GATE} --ignore-unfixed --exit-code 1 --no-progress"
            }
        }

        stage('7. Kubernetes Manifest Scan (Trivy)') {
            steps {
                bat 'docker run --rm -v trivy-cache:/root/.cache/ -v "%CD%:/work" aquasec/trivy:latest config --severity HIGH,CRITICAL --exit-code 1 /work/k8s'
            }
        }

        // ---------- DEPLOY ----------

        stage('8. Check Cluster Secret') {
            steps {
                script {
                    def rc = bat(returnStatus: true, script: "@kubectl -n ${NAMESPACE} get secret healthcare-secrets")
                    if (rc != 0) {
                        error('Secret "healthcare-secrets" not found. Run setup-cluster.bat once, then re-run this build.')
                    }
                }
            }
        }

        stage('9. Deploy to Kubernetes') {
            steps {
                bat 'kubectl apply -f k8s/'
                bat "kubectl -n ${NAMESPACE} set image deployment/healthcare-api api=${IMAGE_NAME}:${IMAGE_TAG}"
                bat "kubectl -n ${NAMESPACE} rollout status deployment/healthcare-api --timeout=180s"
            }
        }

        stage('10. Post-Deploy Checks') {
            steps {
                bat "curl --fail --silent --retry 10 --retry-delay 3 --retry-connrefused ${APP_URL}/health"
                script {
                    // Security regression test: protected endpoint MUST reject requests without a key
                    def code = bat(returnStdout: true,
                        script: '@curl --silent --output NUL --write-out "%%{http_code}" http://localhost:30100/api/patients').trim()
                    echo "Unauthenticated request returned HTTP ${code}"
                    if (code != '401') {
                        error("SECURITY FAILURE: /api/patients answered ${code} without an API key (expected 401)")
                    }
                }
            }
        }

        stage('11. DAST (OWASP ZAP)') {
            when { expression { params.RUN_DAST } }
            steps {
                script {
                    def rc = bat(returnStatus: true,
                        script: 'docker run --rm -v "%CD%:/zap/wrk:rw" ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t http://host.docker.internal:30100/ -r zap-report.html -m 1')
                    if (rc != 0) {
                        unstable("ZAP reported findings or warnings (exit ${rc}). Open zap-report.html in the build artifacts.")
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'zap-report.html, sbom.cdx.json', allowEmptyArchive: true
            script { bat(returnStatus: true, script: 'del /q image.tar') }
        }
        success { echo "DevSecOps pipeline passed. API: ${APP_URL}" }
        failure { echo 'A security gate or deployment step FAILED. Read the first red stage in the console log.' }
    }
}
