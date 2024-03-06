
module.exports = {
    apps: [{
        script: 'api.js',
    }, {
        script: 'worker.js'
    }],

    // Deployment Configuration
    deploy: {
        production: {
            "user": "ubuntu",
            "host": ["192.168.0.13", "192.168.0.14", "192.168.0.15"],
            "ref": "origin/master",
            "repo": "git@github.com:Username/repository.git",
            "path": "/var/www/my-repository",
            "post-deploy": "npm install"
        }
    }
};

pm2 deploy production setup
# Revert to - 1 deployment
$ pm2 deploy production revert 1
$ pm2 deploy production exec "pm2 reload all"


Deployment Lifecycle
"pre-setup" : "echo 'commands or local script path to be run on the host before the setup process starts'",
"post-setup": "echo 'commands or a script path to be run on the host after cloning the repo'",
"pre-deploy" : "pm2 startOrRestart ecosystem.json --env production",
"post-deploy" : "pm2 startOrRestart ecosystem.json --env production",
"pre-deploy-local" : "echo 'This is a local executed command'"

# ~/.ssh/config
Host alias
HostName myserver.com
User username
IdentityFile ~/.ssh/mykey
# Usage: `ssh alias`
# Alternative: `ssh -i ~/.ssh/mykey username@myserver.com`

Host deployment
HostName github.com
User username
IdentityFile ~/.ssh/github_rsa
# Usage:
# git @deployment: username / anyrepo.git
# This is for cloning any repo that uses that IdentityFile.
