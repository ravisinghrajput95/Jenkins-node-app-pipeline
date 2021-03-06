def getVersion(){
    def commitHash =  sh returnStdout: true, script: 'git rev-parse --short HEAD'
    return commitHash
}

pipeline{
    agent any
    environment{
        GIT_COMMIT_HASH = getVersion()
    }

    stages{

        stage('Preparation'){
            steps{
                slackSend color: "good", message: "Status: Pipeline has been Triggered | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
            }
        }

        stage('Code Checkout'){
            steps{
                echo "Pull latest source code from the repository"
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/ravisinghrajput95/Jenkins-node-app-pipeline.git'

            }
        }

        stage('Initialize and Download Dependencies'){
            steps{
                dir('server'){  
                    sh 'npm install'
                    sh 'npm audit fix --force'

                }
            }
        }

        stage('Unit Tests'){
            steps{
                script{
                 def textMessage
                 def inError
                  try{
                    dir('server'){
                      sh 'npm run test:unit' 
                      
                    }
                    dir('server/mochawesome-report'){
                       slackUploadFile filePath: 'mochawesome.html', initialComment: 'Unit test results for the current Build'
                    }
                       
                    textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has passed Unit tests"
                    inError = false
                }

                catch(e){
                    echo "$e"
                    textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has failed on Unit tests"
                    inError = true
                }

                finally{
                    
                    slackSend color: "good", message: "Status: Application is good with the Unit tests  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "

                    if(inError){
                        error("Failed Unit tests")
                        slackSend color: "danger", message: "Status: Unit tests are failed | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "

                    }
                }
            }
        }
    }
        
        stage('Integration Tests'){
            steps{
                script{
                    def textMessage
                    def inError
                    try{
                        dir('server'){
                            sh 'rm -rf mochawesome-report'
                            sh 'npm run test:integration'
                        }

                        dir('server/mochawesome-report'){
                            slackUploadFile filePath: 'mochawesome.html', initialComment: 'Integration test results for the current Build'

                        }
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has passed Integration tests"
                        inError = false
                    }
                    catch(e){
                        echo "$e"
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has failed on Integration tests"
                        inError = true

                    }
                    finally{
                        slackSend color: "good", message: "Status: Application is good with the Integration tests  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
                    if(inError){
                        error("Failed integration tests")
                        slackSend color: "danger", message: "Status: Unit tests are failed | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "

                    }
                }
            }
        }
    }   
        stage('Docker Build'){
            steps{
                script{
                    def textMessage
                    def inError
                    try{
                        sh 'docker build -t rajputmarch2020/nodeapp:${GIT_COMMIT_HASH} .'

                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has passed Integration tests"
                        inError = false
                    }
                    catch(e){
                        echo "$e"
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has failed on Docker image build"
                         inError = true
                    }
                    finally{
                        slackSend color: "good", message: "Status: Docker image build succeed  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
                        if(inError){
                        error("Failed integration tests")
                        slackSend color: "danger", message: "Status: Docker image build failed | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
                    }
                }

            }
        }
    }

        stage('Image scan'){
            steps{
                echo "Scanning image with Trivy"
                script{
                    try{
                        sh 'trivy image --no-progress  --severity CRITICAL rajputmarch2020/nodeapp:${GIT_COMMIT_HASH}'
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has passed Trivy scan"
                        inError = false
                    }
                    catch(e){
                        echo "$e"
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has failed on Trivy Scan"
                        inError = true
                    }
                    finally{
                        slackSend color: "good", message: "Status: Trivy Image scan is successfull  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
                        if(inError){
                        error("Failed integration tests")
                        slackSend color: "danger", message: "Status: Trivy Image scan failed | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
                    }
                }
            }
        }
    }

        stage('Docker push'){
            steps{
                withCredentials([string(credentialsId: 'dockerhub', variable: 'password')]) {
                sh 'docker login -u rajputmarch2020 -p ${password} '
                }
                sh 'docker push rajputmarch2020/nodeapp:${GIT_COMMIT_HASH}'
                slackSend color: "good", message: "Status: Image pushed to Docker Hub  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
            }
        }

        stage('Validate Helm charts using Datree'){
            steps{
                script{
                    try{
                        dir('Helm/'){
                            withEnv(['DATREE_TOKEN=ao1RpL3G3LMRL6eucy37hv']){
                                sh "helm datree test charts/"
                            }
                        }
                    }
                    catch(e){
                        echo "$e"
                        textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has failed on Datree Kubernetes config checks"
                        inError = true

                    }

                    finally{
                        slackSend color: "good", message: "Status: Datree config checks for Kubernetes configs is successfull  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
                        if(inError){
                        error("Datree config check is failed")
                        slackSend color: "danger", message: "Status: Datree config checks for Kubernetes configs is failed | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "

                    }
                }

            }
        }

    } 
        stage('Manual approval'){
            steps{
                script{
                    timeout(10) {
                        mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> Go to build url and approve the deployment request <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "ravisinghrajput005@gmail.com";  
                        input(id: "Deploy Gate", message: "Deploy ${params.project_name}?", ok: 'Deploy')
                    }
                }
            }
        }
        
        stage('Deployment to EKS cluster') {
            steps {
               script{
                   withCredentials([kubeconfigFile(credentialsId: 'kubernetes-config', variable: 'KUBECONFIG')]) {
                        dir('Helm/') {
                          sh 'helm upgrade --install --set image.repository="rajputmarch2020/nodeapp" --set image.tag="${GIT_COMMIT_HASH}" nodeapplication charts/ ' 
                        }
                        slackSend color: "good", message: "Status: Application deployed successfully to AWS EKS cluster | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
                    }
               }
            }
        }
    }    

post{
    success{
        echo "Pipeline executed successfully"
        slackSend color: "good", message: "Status: Pipeline executed successfully  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "

    }
    unstable{
        echo "Build is unstable"
        slackSend color: "yellow", message: "Status: Pipeline executed successfully  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
    }

    aborted{
        echo "Build was aborted"
        slackSend color: "yellow", message: "Build was aborted  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "

    }
    failure{
        echo "Build was failure"
        slackSend color: "danger", message: "Status: Build was failure  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "
    }
    always{
        mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "ravisinghrajput005@gmail.com";  
        echo "Cleaning WS"
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
       }
    }
}
