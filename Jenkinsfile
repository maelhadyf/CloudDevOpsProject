pipeline {
    agent {
        label 'jenkins-slave'
    }


    environment {
        DOCKER_REGISTRY = 'docker.io/maelhadyf'
        OPENSHIFT_SERVER  = 'https://api.ocp-training.ivolve-test.com:6443'
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
                        echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin
                        docker tag java-app:${BUILD_NUMBER} ${DOCKER_REGISTRY}/java-app:${BUILD_NUMBER}
                        docker push ${DOCKER_REGISTRY}/java-app:${BUILD_NUMBER}
                        docker logout ${DOCKER_REGISTRY}
                    '''
                }
            }
        }

        
        stage('Deploy to OpenShift') {
            steps {
                withCredentials([string(credentialsId: 'openshift-credentials', variable: 'TOKEN')]) {
                    sh '''
                        oc login --token=${TOKEN} --server=${OPENSHIFT_SERVER} --insecure-skip-tls-verify=true

                        # Replace variables in deployment.yml
                        sed 's|\${BUILD_NUMBER}|'${BUILD_NUMBER}'|g' deployment.yml > deployment_processed.yml
            
                        # Apply the configuration
                        oc apply -f deployment_processed.yml

                        # Get the Route URL
                        echo "Application is deployed at: \$(oc get route java-app -o jsonpath='{.spec.host}')"
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
