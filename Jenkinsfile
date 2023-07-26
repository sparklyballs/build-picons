pipeline {
	agent {
	label 'DOCKER_BUILD_X86_64'
	}

options {
	skipDefaultCheckout(true)
	buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '5'))
	}

environment {
	CREDS_DOCKERHUB=credentials('420d305d-4feb-4f56-802b-a3382c561226')
	CREDS_GITHUB=credentials('bd8b00ff-decf-4a75-9e56-1ea2c7d0d708')
	CONTAINER_NAME = 'picons'
	CONTAINER_REPOSITORY = 'sparklyballs/picons'
	GITHUB_RELEASE_URL_SUFFIX = 'picons/picons/releases/latest'
	GITHUB_REPOSITORY = 'sparklyballs/build-picons'
	}

stages {

stage('Query Release Version') {
steps {
script{
	env.RELEASE_VER = sh(script: 'curl -u "${SECRETUSER}:${SECRETPASS}" -sX GET "https://api.github.com/repos/${GITHUB_RELEASE_URL_SUFFIX}" \
	| jq -r ".tag_name"', returnStdout: true).trim() 
	}
	}
	}

stage('Checkout Repository') {
steps {
	cleanWs()
	checkout scm
	}
	}

stage ("Do Some Linting") {
steps {
	sh ('curl -o linting-script.sh -L https://raw.githubusercontent.com/sparklyballs/versioning/master/linting-script.sh')
	sh ('/bin/bash linting-script.sh')
	recordIssues enabledForFailure: true, tool: hadoLint(pattern: 'hadolint-result.xml')	
	recordIssues enabledForFailure: true, tool: checkStyle(pattern: 'shellcheck-result.xml')	
	}
	}

stage('Build Application') {
steps {
	sh ('docker buildx build \
	--no-cache \
	--pull \
	-t ${CONTAINER_REPOSITORY}:$BUILD_NUMBER \
	-t ${CONTAINER_REPOSITORY}:${RELEASE_VER} \ 
	--build-arg RELEASE=${RELEASE_VER} \
	.')
	}
	}

stage('Extract Application') {
steps {
	sh ('docker run \
	--rm=true -t -v $WORKSPACE:/mnt \
	$CONTAINER_REPOSITORY:$BUILD_NUMBER')
	}
	}
	}

post {
success {
archiveArtifacts artifacts: 'build/*.tar.bz2'
sshagent (credentials: ['bd8b00ff-decf-4a75-9e56-1ea2c7d0d708']) {
	sh('git tag -f $BUILD_NUMBER')
	sh('git tag -f $RELEASE_VER')
	sh('git push -f git@github.com:$GITHUB_REPOSITORY.git $BUILD_NUMBER')
	sh('git push -f git@github.com:$GITHUB_REPOSITORY.git $RELEASE_VER')	
	}
	}
	}
}
