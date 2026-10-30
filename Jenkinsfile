pipeline {
    agent any

    environment {
        IMAGE_NAME     = 'flask-cicd-demo'
        CONTAINER_NAME = 'flask-cicd-demo'
        HOST_PORT      = '8000'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 15, unit: 'MINUTES')
    }

    triggers {
        // Check GitHub for new commits every minute
        pollSCM('* * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
                sh 'git log -1 --oneline'
            }
        }

        stage('Install dependencies') {
            steps {
                sh '''
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --quiet --upgrade pip
                    pip install --quiet -r requirements-dev.txt
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    . .venv/bin/activate
                    pytest -v --junitxml=test-results.xml
                '''
            }
            post {
                always {
                    junit 'test-results.xml'
                }
            }
        }

        stage('Build Docker image') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest .
                    docker images ${IMAGE_NAME}
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} || true
                    docker run -d --name ${CONTAINER_NAME} \
                        -p ${HOST_PORT}:5000 \
                        -e APP_VERSION=build-${BUILD_NUMBER} \
                        --restart unless-stopped \
                        ${IMAGE_NAME}:${BUILD_NUMBER}
                    sleep 5
                    curl -fsS http://localhost:${HOST_PORT}/health
                    echo
                    docker ps --filter name=${CONTAINER_NAME}
                '''
            }
        }
    }

    post {
        success {
            echo "Build #${BUILD_NUMBER} deployed. Open http://<EC2-PUBLIC-IP>:${HOST_PORT}"
        }
        failure {
            echo "Build #${BUILD_NUMBER} failed. Check the stage that turned red."
        }
        cleanup {
            sh 'docker image prune -f || true'
        }
    }
}
