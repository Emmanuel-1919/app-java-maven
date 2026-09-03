pipeline {
    agent any

    environment {
        TARGET_ENV = "${env.BRANCH_NAME == 'develop' ? 'dev' : (env.BRANCH_NAME == 'qa' ? 'qa' : 'prod')}"
    }

    stages {
        stage('Test') {
            agent {
                docker { image 'maven:3.9.6-eclipse-temurin-21' }
            }
            steps {
                    sh '''
                    ./mvnw test
                    '''
            }
        }
        stage('Docker Build') {
            steps {
                echo 'Construyendo imagen Docker...'
                    sh "docker build -t localhost:5000/app-java-maven:\$(git rev-parse --short HEAD) ."
                    sh "docker push localhost:5000/app-java-maven:\$(git rev-parse --short HEAD)"
                
            }
        }
                stage('Deploy') {
            steps {
                dir('manifests') {
                    checkout([
                         $class: 'GitSCM',
                         branches: [[name: "*/${env.BRANCH_NAME}"]],
                         userRemoteConfigs: [[
                            url: 'git@github.com:Emmanuel-1919/Devops-cicd.git',
                            credentialsId: 'github-devops-cicd'
                        ]]
                   ])
                }

                echo "Desplegando en el ambiente: ${TARGET_ENV}"

                sh '''
                    IMAGE_TAG=$(git rev-parse --short HEAD)

                    kubectl apply \
                        -f manifests/k8s/${TARGET_ENV}/app-java-maven-deployment.yaml

                    kubectl set image \
                        deployment/app-java-maven \
                        app-java-maven=local-registry:5000/app-java-maven:${IMAGE_TAG} \
                        -n ${TARGET_ENV}

                    kubectl apply \
                        -f manifests/k8s/${TARGET_ENV}/app-java-maven-service.yaml
                '''
            }
        }
    }
}
