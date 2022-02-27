pipeline {
     environment {
       IMAGE_NAME = "alpine"
       IMAGE_TAG = "latest"
       STAGING = "akaboidi-staging"
       PRODUCTION = "akaboidi-production"
       IMAGE_REPO = "akaboidi"
     }
     agent none
     stages {
         stage('Build image') {
             agent any
             steps {
                script {
                  sh 'docker build -t akaboidi/$IMAGE_NAME:$IMAGE_TAG .'
                }
             }
        }
        stage('Run container based on builded image') {
            agent any
            steps {
               script {
                 sh '''
                    docker run --name $IMAGE_NAME -d -p 80:5000 -e PORT=5000 akaboidi/$IMAGE_NAME:$IMAGE_TAG
                    sleep 5
                 '''
               }
            }
       }
       stage('Test image') {
           agent any
           steps {
              script {
                sh '''
                    curl http://localhost | grep -q "Hello world"
                '''
              }
           }
      }
      stage('Clean Container') {
          agent any
          steps {
             script {
               sh '''
                  docker stop $IMAGE_NAME
                  docker rm $IMAGE_NAME
               '''
             }
          }
     }
     stage('Push image on dockerhub') {
           agent any 
           environment {
                DOCKERHUB_LOGIN = credentials('dockerhub_boakat')
                
            }

           steps {
               script {
                   sh '''
		               docker login --username ${DOCKERHUB_LOGIN_USR} --password ${DOCKERHUB_LOGIN_PSW}
                   docker push ${IMAGE_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
                   '''
               }
           }
        }
     stage('Push image in staging and deploy it') {
       when {
              expression { GIT_BRANCH == 'origin/master' }
            }
      agent any
      environment {
          HEROKU_API_KEY = credentials('heroku_api_key')
      }
      steps {
          script {
            sh '''
              heroku container:login
              heroku create $STAGING || echo "project already exist"
              heroku container:push -a $STAGING web
              heroku container:release -a $STAGING web
            '''
          }
        }
     }
     stage('Test Staging deployment') {
       when {
              expression { GIT_BRANCH == 'origin/master' }
            }
           agent any
           steps {
              script {
                sh '''
                    curl https://${STAGING}.herokuapp.com | grep -q "Hello world"
                '''
              }
           }
      }
     stage('Push image in production and deploy it') {
       when {
              expression { GIT_BRANCH == 'origin/master' }
            }
      agent any
      environment {
          HEROKU_API_KEY = credentials('heroku_api_key')
      }  
      steps {
          script {
            sh '''
              heroku container:login
              heroku create $PRODUCTION || echo "project already exist"
              heroku container:push -a $PRODUCTION web
              heroku container:release -a $PRODUCTION web
            '''
          }
        }
     }
     stage('Test Prod deployment') {
       when {
              expression { GIT_BRANCH == 'origin/master' }
            }
           agent any
           steps {
              script {
                sh '''
                    curl https://${PRODUCTION}.herokuapp.com | grep -q "Hello world"
                '''
              }
           }
      }
  }
}
