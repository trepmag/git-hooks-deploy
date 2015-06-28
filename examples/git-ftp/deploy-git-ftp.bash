#!/usr/bin/env bash
#
# Git-hooks-deploy deploy script example that use git-ftp.
# See https://github.com/trepmag/git-hooks-deploy.
#
# This script require to have a none bare repository for each git bare repository.
# Here is the required filesystem structure:
# - ~/repositories/example.git
# - ~/repositories-not-bare/example.git
#

# Set arguments
GIT_BRANCH=$1
GIT_FTP_SCOPE=$2
GIT_FTP_URL=$3
GIT_FTP_USER=$4
GIT_FTP_PASSWORD=$5
if [[ "$2" == "--args-file" && -n "$3" && -e "$3" ]]; then
	# Read argument from config file
	deploy_cfg=$3
	deploy_cfg=$(readlink $deploy_cfg || echo $deploy_cfg)
	source $deploy_cfg
fi

# Validate arguments
if [[ -z "$GIT_BRANCH" || -z "$GIT_FTP_SCOPE" || -z "$GIT_FTP_URL" || -z "$GIT_FTP_USER" || -z "$GIT_FTP_PASSWORD" ]] ; then
	echo "Some arguments are missing for $0 script!"
	echo "Aborting deploy..."
	exit 1
fi

MSG_PREFIX="Deploy process"
REPOSITORY_NAME=${PWD##*/}
PROJECT_NAME=${REPOSITORY_NAME%\.git}
REPOSITORY_NOT_BAR_DIR=`readlink -f ../../repositories-not-bare`"/$PROJECT_NAME"

if [ ! -d $REPOSITORY_NOT_BAR_DIR ]; then
	echo "=== $MSG_PREFIX 0/3: Clone '$REPOSITORY_NAME' repository:"
	git clone . ../../repositories-not-bare/$PROJECT_NAME
fi
cd $REPOSITORY_NOT_BAR_DIR

# Set git-ftp scope with deploy environment setting
git config git-ftp.$GIT_FTP_SCOPE.url $GIT_FTP_URL
git config git-ftp.$GIT_FTP_SCOPE.user $GIT_FTP_USER
git config git-ftp.$GIT_FTP_SCOPE.password $GIT_FTP_PASSWORD

unset GIT_DIR

echo "=== $MSG_PREFIX 1/3: Checkout '$GIT_BRANCH' branch on intermediate non bare repository:"
git fetch
git checkout $GIT_BRANCH
if [ $? -ne 0 ]; then
	echo "Aborting deploy task..."
	exit $?
fi

echo "=== $MSG_PREFIX 2/3: Pull '$GIT_BRANCH' branch on intermediate non bare repository:"
git pull origin $GIT_BRANCH

echo "=== $MSG_PREFIX 3/3: Ftp push '$GIT_BRANCH' branch to '$GIT_FTP_SCOPE' environment:"
git-ftp push -s $GIT_FTP_SCOPE

