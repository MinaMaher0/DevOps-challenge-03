pipeline {
    agent none
    stages {
        stage('build, test and deploy to Development environment') {
            when {
                branch 'development'  
            }
            agent { label 'development' }
            stages{
                stage('Testing'){
                    steps {
                        sh 'docker build -t tornado:${BUILD_NUMBER} .'
                        sh 'docker run --rm --name testApp tornado:${BUILD_NUMBER}'
                    }
                }
                stage('clean development envirnment') {
                    steps {
                        catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS') {
                            sh 'docker stop $(docker ps -q)'
                            sh 'docker rm $(docker ps -a -q)'
                        }
                    }
                }
                stage('deploy to development environment'){
                    environment {
                        ENV_TYPE = 'DEV'
                        IMAGE_TAG = '${BUILD_NUMBER}'
                    }
                    steps {
                        sh 'docker-compose up -d --build'
                    }
                }
            }
        }
        stage('build, test, push and deploy to Production environment') {
            when {
                branch 'master'  
            }
            agent { label 'k8s-master' }
            stages{
                stage('Testing'){
                    steps {
                        sh 'docker build -t tornado:${BUILD_NUMBER} .'
                        sh 'docker run --rm --name testApp tornado:${BUILD_NUMBER}'
                    }
                }
                stage('push app image to docker hub') {
                    environment {
                        docker_username     = credentials('docker_username')
                        docker_password = credentials('docker_password')
                    }
                    steps {
                        sh 'docker login -u $docker_username -p $docker_password'
                        sh 'docker tag tornado:${BUILD_NUMBER} $docker_username/tornado:${BUILD_NUMBER}'
                        sh 'docker push $docker_username/tornado:${BUILD_NUMBER}'
                    }
                }
                stage('deploy to production envirnment'){
                    environment {
                        ENV_TYPE = 'PROD'
                    }
                    steps {
                        sh 'sed -i \'s/IMAGE_TAG/${BUILD_NUMBER}/g\' Kubernetes/tornado_deployment.yml'
                        sh '''
                            export KUBECONFIG=/home/ubuntu/.kube/config
                            kubectl apply -f Kubernetes/redis_deployment.yml
                            kubectl apply -f Kubernetes/redis_svc.yml
                            kubectl apply -f Kubernetes/tornado_deployment.yml
                            kubectl apply -f Kubernetes/tornado_svc.yml
                        '''
                    }
                }
            }
        }
    }
}
