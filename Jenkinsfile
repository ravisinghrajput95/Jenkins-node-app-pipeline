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
                 DATE_TAG = java.time.LocalDate.now()
                 DATETIME_TAG = java.time.LocalDateTime.now()
                 def textMessage
                 def inError
                  try{
                    dir('server'){
                      sh 'npm run test:unit' 
                      
                    }
                    dir('mochawesome-report'){
                       slackUploadFile filePath: 'mochawesome.html', initialComment: 'Unit test results for the current Build'
                    }
                       
                    textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has passed unit tests"
                    inError = false
                }

                catch(e){
                    echo "$e"
                    textMessage = "Commit hash: $GIT_COMMIT_HASH -- Has failed on unit tests"
                    inError = true
                }

                finally{
                    
                    slackSend color: "good", message: "Status: Application is good with the Unit tests  | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "

                    if(inError){
                        error("Failed integration tests")
                        slackSend color: "danger", message: "Status: Unit tests are failed | Job: ${env.JOB_NAME} | Build number ${env.BUILD_NUMBER} "

                    }
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