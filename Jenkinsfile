pipeline {
    agent any
    environment {
        RESULTS_DIR = 'load_test_results'
        SCRIPT_NAME = 'main.sh' // Name of your load testing script
        GIT_REPO = 'https://github.com/favxlaw/Load-Testing_Script.git' // Replace with your repo
        URL = 'https://insightglobal.com/' // Target URL
        CONCURRENT_REQUESTS = '10'
        DURATION = '5'
        CUSTOM_HEADER = 'Authorization: Bearer YOUR_TOKEN_HERE' // Optional custom header
    }
    stages {
        stage('Checkout Code') {
            steps {
                echo 'Cloning repository...'
                git branch: 'main', url: "${GIT_REPO}"
            }
        }
        stage('Prepare Environment') {
            steps {
                echo 'Setting up environment...'
                sh 'mkdir -p $RESULTS_DIR'
                sh 'chmod +x $SCRIPT_NAME'
            }
        }
        stage('Run Load Test') {
            steps {
                echo 'Executing load test...'
                sh "./$SCRIPT_NAME ${URL} ${CONCURRENT_REQUESTS} ${DURATION} \"${CUSTOM_HEADER}\""
            }
        }
        stage('Archive Results') {
            steps {
                echo 'Archiving load test results...'
                archiveArtifacts artifacts: '${RESULTS_DIR}/*', allowEmptyArchive: true
            }
        }
    }
    post {
        always {
            echo 'Pipeline execution completed!'
            cleanWs()
        }
        failure {
            echo 'Pipeline failed. Please check logs for details.'
        }
    }
}