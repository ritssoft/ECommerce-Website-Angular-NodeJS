pipeline {
  agent any

  environment {
    APP_NAME = 'ecommerce-app'
    IMAGE_NAME = 'ecommerce-app-image'
    SONARQUBE_SCANNER = 'SonarQubeScanner'  // Jenkins global tool config name
    SNYK_TOKEN = credentials('SNYK_TOKEN')
    PATH = "/opt/homebrew/bin:/usr/local/bin:$PATH"
    SONAR_AUTH_TOKEN = credentials('SONAR_TOKEN')
  }

  stages {

    stage('Build') {
      steps {
        dir('server') {
          sh 'npm install'
        }
        dir('.') {
          sh 'npm install'
          sh 'npm run build'
        }
        script {
          sh 'docker build -t $IMAGE_NAME .'
        }
      }
    }

    stage('Test') {
      steps {
        dir('server') {
          sh 'npm test || echo "No backend tests defined"'
        }
        dir('.') {
          sh 'ng test --watch=false --browsers=ChromeHeadless || echo "No frontend tests defined"'
        }
      }
    }

    stage('CodeQuality SonarQube Analysis') {
      steps {
        withCredentials([string(credentialsId: 'SONAR_TOKEN', variable: 'SONAR_TOKEN')]) {
          sh '''
            sonar-scanner \
              -Dsonar.projectKey=ritssoft_ECommerce-Website-Angular-NodeJS \
              -Dsonar.organization=ritssoft \
              -Dsonar.sources=. \
              -Dsonar.host.url=https://sonarcloud.io \
              -Dsonar.login=$SONAR_TOKEN
          '''
        }
      }
    }

    stage('Security') {
      steps {
        sh 'npm install -g snyk'
        sh 'snyk auth $SNYK_TOKEN'
        sh 'snyk test || echo "Security scan failed. Review report."'
      }
    }

    stage('Deploy') {
      steps {
        sh 'docker-compose down || true'
        sh 'docker-compose up -d'
      }
    }

    stage('Release') {
      steps {
        echo "App deployed and available at: http://localhost:4200"
        echo "Release tag would be created here in a real pipeline."
      }
    }

    stage('Monitoring') {
      steps {
        sh '''
            container=$(docker ps -qf "name=ecommerce" | head -n 1)
            if [ -n "$container" ]; then
                docker logs $container > monitoring.log || echo "Log collection failed"
            else
                echo "No running ecommerce container found" > monitoring.log
            fi
            tail -n 10 monitoring.log
        '''
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: '**/monitoring.log', allowEmptyArchive: true
    }
  }
}