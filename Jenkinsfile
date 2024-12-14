pipeline {
    agent any
    environment {
        RESULTS_DIR = 'load_test_results'
        SCRIPT_NAME = 'main.sh' 
        GIT_REPO = 'https://github.com/favxlaw/Load-Testing_Script.git' 
        TARGET_URL = 'https://insightglobal.com/' 
        CONCURRENT_REQUESTS = '10'
        DURATION = '5'
        //CUSTOM_HEADER = 'Authorization: Bearer YOUR_TOKEN_HERE' 
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
                sh "./$SCRIPT_NAME ${TARGET_URL} ${CONCURRENT_REQUESTS} ${DURATION} \"${CUSTOM_HEADER}\""
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
