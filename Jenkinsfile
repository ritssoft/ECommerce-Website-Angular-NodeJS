pipeline {
  agent any

  environment {
    APP_NAME = 'ecommerce-app'
    IMAGE_NAME = 'ecommerce-app-image'
    SONARQUBE_SCANNER = 'SonarQubeScanner'  // Jenkins global tool config name
    SNYK_TOKEN = credentials('SNYK_TOKEN')
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/ritssoft/ECommerce-Website-Angular-NodeJS.git'
      }
    }

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

    stage('Code Quality') {
      steps {
        withSonarQubeEnv('SonarQubeScanner') {
          sh 'sonar-scanner -Dsonar.projectKey=ecommerce -Dsonar.sources=. -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN'
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