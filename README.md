**Git-hooks-deploy** is a [git-hooks!](https://github.com/icefox/git-hooks) hook which trigger deployment tasks.

A task consist of config file which define:
- The deploy type (ftp, etc, ...)
- The deploy script location
- Parameters for the deploy script

This config file is to be located in a Git project (bare Git repository).

# Config file example
Here is a deploy task config file for a Git project:
```
# Git-hooks-deploy parameters config file
# ~/repositories/example.git/deploy-master.cfg

# Git-hooks-deploy parameters
DEPLOY_TYPE="ftp (git-ftp)"
DEPLOY_SCRIPT=~/bin/deploy-git-ftp.bash

# Deploy scripts parameters (will be loaded in the script scope)
GIT_FTP_SCOPE=develop
GIT_FTP_URL=ftp.example.com/htdocs
GIT_FTP_USER=an_ftp_user
GIT_FTP_PASSWORD=1234
```

# Installation
Install deploy.bash in ~/.git_hooks/post-receive/ and then install git-hooks for a project, e.g.:
```
$ cd example.git/
$ git-hooks install
```

# Git-ftp deploy task
There is a deploy task example included:
```
examples/git-ftp/deploy-master.cfg
examples/git-ftp/deploy-git-ftp.bash
```
Copy the deploy-master.cfg config file in a Git project and edit the paramters.

Also, this script require to have a none bare repository for each git bare repository.
Here is the required filesystem structure:
- ~/repositories/example.git
- ~/repositories-not-bare/example.git
