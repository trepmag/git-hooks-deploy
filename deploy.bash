#!/usr/bin/env bash
#
# Git-hooks-deploy. See https://github.com/trepmag/git-hooks-deploy.
#

DEPLOY_ID=`uuidgen`
LOG_FILE=~/logs/deploy
LOG_FILE="$LOG_FILE-$DEPLOY_ID"

exec 2> >(tee "$LOG_FILE".err)
exec > >(tee "$LOG_FILE")

function run_deploy
{
	while read oldrev newrev refname
	do
		git_branch=$(git rev-parse --symbolic --abbrev-ref $refname)
		deploy_cfg=deploy-$git_branch.cfg
		if test -e $deploy_cfg; then
			deploy_cfg=$(readlink $deploy_cfg || echo $deploy_cfg)
			echo "Found '$deploy_cfg' deploy config file for '${PWD##*/}' repository; reading parameters..."
			source $deploy_cfg
			if [[ -z "$DEPLOY_TYPE" || -z "$DEPLOY_SCRIPT" ]]; then
				echo "Notice: Config file is missing its 'DEPLOY_NAME' or 'DEPLOY_SCRIPT' parameters!"
			else
				if test -e $DEPLOY_SCRIPT; then
					echo "Deploy task id '$DEPLOY_ID' of type '$DEPLOY_TYPE' is starting..."
					DEPLOY_SCRIPT=$(readlink $DEPLOY_SCRIPT || echo $DEPLOY_SCRIPT)
					$DEPLOY_SCRIPT $git_branch --args-file $deploy_cfg
				else
					echo "Notice: Deploy script not found!"
				fi
			fi
		else
			echo "Notice: No '$deploy_cfg' config file found to deploy '$git_branch' git_branch for '${PWD##*/}' repository!"
		fi
	done
}

case "${1}" in
	--about )
		echo -n "Deploy script; place a deploy config 'deploy-<branch name>.cfg' file into a bare repository directory."
		;;
	* )
		run_deploy "$@"
	;;
esac
