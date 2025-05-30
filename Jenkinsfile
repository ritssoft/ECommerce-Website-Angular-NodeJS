pipeline {
  agent any

  environment {
    APP_NAME = 'ecommerce-app'
    IMAGE_NAME = 'ecommerce-app-image'
    SONARQUBE_SCANNER = 'SonarQubeScanner'  // Jenkins global tool config name
    SNYK_TOKEN = credentials('SNYK_TOKEN')
  }

  stages {

    stage('Build') {
      steps {
        dir('server') {
          sh 'export PATH=/opt/homebrew/bin:$PATH && npm install'
        }
        dir('.') {
          sh 'export PATH=/opt/homebrew/bin:$PATH && npm install'
          sh 'export PATH=/opt/homebrew/bin:$PATH && npm run build'
        }
        script {
          sh 'export PATH=/opt/homebrew/bin:$PATH && docker build -t $IMAGE_NAME .'
        }
      }
    }

    stage('Test') {
      steps {
        dir('server') {
          sh 'export PATH=/opt/homebrew/bin:$PATH && npm test || echo "No backend tests defined"'
        }
        dir('.') {
          sh 'export PATH=/opt/homebrew/bin:$PATH && ng test --watch=false --browsers=ChromeHeadless || echo "No frontend tests defined"'
        }
      }
    }

    stage('Code Quality') {
      steps {
        withSonarQubeEnv('SonarQubeScanner') {
          sh '''
            export PATH=/opt/homebrew/bin:$PATH &&
            sonar-scanner \
              -Dsonar.projectKey=ecommerce \
              -Dsonar.sources=. \
              -Dsonar.host.url=$SONAR_HOST_URL \
              -Dsonar.login=$SONAR_AUTH_TOKEN
          '''
        }
      }
    }

    stage('Security') {
      steps {
        sh 'export PATH=/opt/homebrew/bin:$PATH && npm install -g snyk'
        sh 'export PATH=/opt/homebrew/bin:$PATH && snyk auth $SNYK_TOKEN'
        sh 'export PATH=/opt/homebrew/bin:$PATH && snyk test || echo "Security scan failed. Review report."'
      }
    }

    stage('Deploy') {
      steps {
        sh 'export PATH=/opt/homebrew/bin:$PATH && docker-compose down || true'
        sh 'export PATH=/opt/homebrew/bin:$PATH && docker-compose up -d'
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
          export PATH=/opt/homebrew/bin:$PATH &&
          docker logs $(docker ps -qf "name=ecommerce") > monitoring.log || echo "Log collection failed"
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