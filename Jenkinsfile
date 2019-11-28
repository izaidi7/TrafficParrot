pipeline {
  agent {
    label 'ubuntu_docker_label'
  }
  options {
    checkoutToSubdirectory('src/github.com/pkbinfoblox/TrafficParrot')
  }
  environment {
    DIRECTORY = "src/github.com/pkbinfoblox/TrafficParrot"
  }
  stages {
    stage('S3download') {
      steps {
		withAWS(credentials:'awscredentials') {
        s3Download(file: 'key', bucket: 'test', path: $DIRECTORY)
      }
    }
    }  
  stage("Build") {
      steps {
        withDockerRegistry([credentialsId: "dockerhub-bloxcicd", url: ""]) {
          sh "cd $DIRECTORY && 'docker build --build-arg TRAFFIC_PARROT_ZIP=trafficparrot-linux-x64-jre-5.6.0.zip --build-arg ACCEPT_LICENSE=true --tag trafficparrot:1.0.0 --file Dockerfile .'"
        }
      }
    }
    stage("Push Latest") {
      steps {
        withDockerRegistry([credentialsId: "dockerhub-bloxcicd", url: ""]) {
          sh "cd $DIRECTORY && docker push"
        }
        withAWS(region:'us-east-1', credentials:'CICD_HELM') {
          sh "cd $DIRECTORY && make push-chart"
        }
        dir("${WORKSPACE}/${DIRECTORY}") {
          archiveArtifacts artifacts: 'charts/*.tgz'
          archiveArtifacts artifacts: 'build/build.properties'
        }
      }
    }
  }
  post {
    always {
        sh "cd $DIRECTORY && make clean || true"
        cleanWs()
    }
  }
}

