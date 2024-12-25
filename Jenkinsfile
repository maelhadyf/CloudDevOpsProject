pipeline {
    agent {
        label 'jenkins-slave'
    }


    environment {
        appGitUrl = 'https://github.com/maelhadyf/CloudDevOpsProject.git'
        appBranch = 'main'  // or whatever branch you're using
        dockerRegistry = 'maelhadyf'
    }

    
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        disableConcurrentBuilds()
    }
    
    stages {
        stage('Checkout Application') {
            steps {
                deleteDir()

                checkout scm  // Simple one-liner
            }
        }
        
        stage('Unit Test') {

            tools {
                jdk 'JDK11'  // Must be configured in Jenkins Global Tool Configuration
            }
            steps {
                dir('app-code') {
                    sh '''
                        java -version

                        # Make gradlew executable
                        chmod +x ./gradlew

                        # Run tests
                        ./gradlew test
                    '''
                }
            }
            post {
                always {
                    junit '**/build/test-results/test/*.xml'
                }
            }
        }
        
        stage('Build JAR') {
            steps {
                dir('app-code') {
                    sh '''
                        ./gradlew clean build -x test
                    '''
                }
            }
        }
        
        stage('SonarQube Analysis') {

            tools {
                jdk 'JDK17'  // Must be configured in Jenkins Global Tool Configuration
            }
            steps {
                dir('app-code') {
                    withCredentials([string(credentialsId: 'sonar-credentials', variable: 'TOKEN')]) {
                        sh '''
                            java -version

                            ./gradlew sonar \
                            -Dsonar.projectKey=java-app \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.token=${TOKEN}
                        '''
                    }
                }
            }
        }
        
        stage('Build Image') {
            steps {
                dir('app-code') {
                    
                    sh """
                        docker build -t java-app:${BUILD_NUMBER} .
                     """
                    
                }
            }
        }
        
        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-registry-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "${DOCKER_PASS}" | docker login ${dockerRegistry} -u "${DOCKER_USER}" --password-stdin
                        docker tag java-app:${BUILD_NUMBER} ${dockerRegistry}/java-app:${BUILD_NUMBER}
                        docker push ${dockerRegistry}/java-app:${BUILD_NUMBER}
                        docker logout ${dockerRegistry}
                    '''
                }
            }
        }

        
        stage('Deploy to OpenShift') {
            steps {
                withCredentials([string(credentialsId: 'openshift-credentials', variable: 'TOKEN')]) {
                    sh '''
                        oc login --token=${TOKEN}

                        # Update deployment with local image
                        oc set image deployment/java-app java-app=docker://localhost:5000/java-app:${BUILD_NUMBER} --local
                        
                        # Create or update service to expose port 8081
                        oc create service clusterip java-app --tcp=8081:8081 --dry-run=client -o yaml | oc apply -f -
                        
                        # Create route to expose the service
                        oc expose service java-app --port=8081 --target-port=8081 || true
                        
                        # Wait for rollout to complete
                        oc rollout status deployment/java-app
                    '''
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
