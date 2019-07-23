pipeline {
  agent {
    kubernetes {
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: some-label-value
spec:
  containers:
  - name: hugo
    image: kenmoini/jenkins-agent-hugo:latest
    command:
    - cat
    tty: true
  - name: busybox
    image: busybox
    command:
    - cat
    tty: true
"""
    }
  }
  stages {

    stage('Clone sources') {
      steps {
        container('hugo') {
            withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-builder-git-key', keyFileVariable: 'SSH_KEY')]) {
                sh 'echo ssh -i $SSH_KEY -l git -o StrictHostKeyChecking=no \\"\\$@\\" > local_ssh.sh'
                sh 'chmod +x local_ssh.sh'
                sh 'apk update'
                sh 'apk --update -U --no-cache add git openssh-client ca-certificates bash'
                withEnv(['GIT_SSH=./local_ssh.sh']) {
                    sh 'git clone git@github.com:kenmoini/site-kenmoini.com.git'
                    sh 'cd site-kenmoini.com && git submodule update --init'
                    sh('cd site-kenmoini.com && git checkout --orphan static-branch')
                }
            }
        }
      }
    }
    stage('Run Hugo') {
      steps {
        container('hugo') {
          sh 'cd site-kenmoini.com && hugo'
        }
        //container('busybox') {
        //  sh '/bin/busybox'
        //}
      }
    }
    stage('Push it out') {
        steps {
            container('hugo') {
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-builder-git-key', keyFileVariable: 'SSH_KEY')]) {
                    sh('git config --global user.email "ken@kenmoini.com"')
                    sh('git config --global user.name "Kemo Jenkins Deployer"')
                    sh('cd site-kenmoini.com && git add public/ Dockerfile')
                    sh('cd site-kenmoini.com && git commit -m "Built site, deploying now"')
                    sh 'cd site-kenmoini.com && echo ssh -i $SSH_KEY -l git -o StrictHostKeyChecking=no \\"\\$@\\" > local_ssh.sh'
                    sh 'cd site-kenmoini.com && chmod +x local_ssh.sh'
                    withEnv(['GIT_SSH=./local_ssh.sh']) {
                        sh("cd site-kenmoini.com && git push --force origin static-branch:static-branch")
                    }
                }
            }
        }
    }
    stage('Zip it up') {
      steps {
        container('hugo') {
            sh 'tar zcf kenmoini.com.tar.gz site-kenmoini.com/'
            
        }
      }
    }
    //TODO: push to SonaType
    stage ("Wait for Docker Hub to Build...") {
        echo "Waiting 5 minutes for deployment to complete prior to redeploying on K8s"
        sleep(time:5,unit:"MINUTES")
    }
    //TODO: Figure out how to get K8s to roll the deployment...
  }
}
