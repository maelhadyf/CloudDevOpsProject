@Library('shared-library') _

def appGitUrl = 'https://github.com/your-org/app-repo.git'
def appBranch = 'main'
def dockerRegistry = 'your-registry.com'
def imageTag = ''

pipeline {
    agent {
        label 'jenkins-slave'
    }
    
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Checkout Application') {
            steps {
                dir('app') {
                    git branch: appBranch,
                        credentialsId: 'git-credentials',
                        url: appGitUrl
                }
                script {
                    imageTag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                }
            }
        }
        
        stage('Unit Test') {
            steps {
                dir('app') {
                    withMaven(maven: 'Maven3', jdk: 'JDK11') {
                        sh 'mvn test'
                    }
                }
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }
        
        stage('Build JAR') {
            steps {
                dir('app') {
                    withMaven(maven: 'Maven3', jdk: 'JDK11') {
                        sh 'mvn clean package -DskipTests'
                    }
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                dir('app') {
                    withSonarQubeEnv('SonarQube') {
                        withMaven(maven: 'Maven3', jdk: 'JDK11') {
                            sh """
                                mvn sonar:sonar \
                                -Dsonar.projectKey=your-project \
                                -Dsonar.host.url=http://localhost:9000
                            """
                        }
                    }
                }
            }
        }
        
        stage('Build Image') {
            steps {
                dir('app') {
                    
                    sh """
                        docker build -t java-app:${BUILD_NUMBER} .
                     """
                    
                }
            }
        }
        
        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-registry-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo \$DOCKER_PASS | docker login ${dockerRegistry} -u \$DOCKER_USER --password-stdin
                        docker tag java-app:${BUILD_NUMBER} ${dockerRegistry}/java-app:${BUILD_NUMBER}
                        docker push ${dockerRegistry}/java-app:${imageTag}
                        docker push ${dockerRegistry}/java-app:latest
                        docker logout ${dockerRegistry}
                    """
                }
            }
        }

        
        stage('Deploy to OpenShift') {
            steps {
                withCredentials([string(credentialsId: 'openshift-credentials', variable: 'TOKEN')]) {
                    sh """
                        oc login --token=${TOKEN}
                        oc set image deployment/your-app your-app=${dockerRegistry}/your-app:${BUILD_NUMBER}
                        oc rollout status deployment/your-app
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        failure {
            // Add notification logic here
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline succeeded!'
        }
    }
}
