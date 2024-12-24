
def appGitUrl = 'https://github.com/maelhadyf/CloudDevOpsProject.git'
def appBranch = 'main'
def dockerRegistry = 'maelhadyf'

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
                dir('app-code') {
                    withCredentials([usernamePassword(credentialsId: 'git-credentials', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        sh '''
                            git config --local credential.helper "!f() { echo username=\\$GIT_USERNAME; echo password=\\$GIT_PASSWORD; }; f"
                            git clone ${appGitUrl} .
                            git checkout ${appBranch}
                            git config --local --unset credential.helper
                        '''
                    }
                }
            }
        }
        
        stage('Unit Test') {
            steps {
                dir('app-code') {
                    withMaven(maven: 'Maven3', jdk: 'JDK21') {
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
                dir('app-code') {
                    withMaven(maven: 'Maven3', jdk: 'JDK21') {
                        sh 'mvn clean package -DskipTests'
                    }
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                dir('app-code') {
                    withMaven(maven: 'Maven3', jdk: 'JDK21') {
                        sh """
                            mvn sonar:sonar \
                            -Dsonar.projectKey=java-app \
                            -Dsonar.host.url=http://localhost:9000
                        """
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
                    sh """
                        echo \$DOCKER_PASS | docker login ${dockerRegistry} -u \$DOCKER_USER --password-stdin
                        docker tag java-app:${BUILD_NUMBER} ${dockerRegistry}/java-app:${BUILD_NUMBER}
                        docker push ${dockerRegistry}/java-app:${BUILD_NUMBER}
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

                        # Update deployment with local image
                        oc set image deployment/java-app java-app=docker://localhost:5000/java-app:${BUILD_NUMBER} --local
                        
                        # Create or update service to expose port 8081
                        oc create service clusterip java-app --tcp=8081:8081 --dry-run=client -o yaml | oc apply -f -
                        
                        # Create route to expose the service
                        oc expose service java-app --port=8081 --target-port=8081 || true
                        
                        # Wait for rollout to complete
                        oc rollout status deployment/java-app
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