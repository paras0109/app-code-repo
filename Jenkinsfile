pipeline {
  agent any

  environment {
    PROJECT_ID = 'free-trail-458302'
    REGION = 'us-central1'
    IMAGE_NAME = 'frontend'
    REPO_PATH = "${REGION}-docker.pkg.dev/${PROJECT_ID}/new-test/${IMAGE_NAME}"
    SHORT_SHA = ''
  }

  stages {
    stage('Checkout Source') {
      steps {
        checkout scm
        script {
          SHORT_SHA = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        }
      }
    }

    stage('Authenticate Docker with Artifact Registry') {
      steps {
        withCredentials([file(credentialsId: 'gcp-service-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
          sh '''
            gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
            gcloud config set project free-trail-458302
            gcloud auth configure-docker us-central1-docker.pkg.dev --quiet
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          docker build -t ${REPO_PATH}:${SHORT_SHA} .
        """
      }
    }

    stage('Push Docker Image') {
      steps {
        sh """
          docker push ${REPO_PATH}:${SHORT_SHA}
        """
      }
    }

    stage('Update Helm Repo and Push') {
      steps {
        withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
          sh """
            git config --global user.email "paras.n0109@gmail.com"
            git config --global user.name "paras0109"
            git clone https://x-access-token:${GITHUB_TOKEN}@github.com/paras0109/helm-deploy-repo.git
            cd helm-deploy-repo
            sed -i 's/tag:.*/tag: ${SHORT_SHA}/' values.yaml
            git add values.yaml
            git commit -m "Update image tag to ${SHORT_SHA}" || echo "No changes to commit"
            git push https://x-access-token:${GITHUB_TOKEN}@github.com/paras0109/helm-deploy-repo.git HEAD:main
          """
        }
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline completed successfully"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}
