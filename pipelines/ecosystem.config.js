
module.exports = {
    apps: [{
        script: "./node_modules/nuxt/bin/nuxt.js",
    }, {
        script: 'worker.js'
    }],

    // Deployment Configuration
    deploy: {
        production: {
            name: process.env.NUXT_ENV_PROJECT_NAME,
            
            "instances": "max", // Or a number of instances
            "cwd": '/var/www/ingotbrokers-website/',
            "script": "./node_modules/nuxt/bin/nuxt.js",
            "args": "start",
            "exec_mode": "cluster",
            "max_memory_restart": "500M",
            "log_date_format": "YYYY-MM-DD HH:mm Z",
            "time": true,

            "user": "ubuntu",
            "host": ["192.168.0.13", "192.168.0.14", "192.168.0.15"],
            "ref": "origin/master",
            "repo": "git@github.com:Username/repository.git",
            "path": "/var/www/my-repository",
            "post-deploy": "npm install"
        }
    }
};

; pm2 deploy production setup
    ; Revert to - 1 deployment
    ; pm2 deploy production revert 1
    ; pm2 deploy production exec "pm2 reload all"


    ; Deployment Lifecycle
    ; "pre-setup" : "echo 'commands or local script path to be run on the host before the setup process starts'",
; "post-setup": "echo 'commands or a script path to be run on the host after cloning the repo'",
; "pre-deploy" : "pm2 startOrRestart ecosystem.json --env production",
; "post-deploy" : "pm2 startOrRestart ecosystem.json --env production",
; "pre-deploy-local" : "echo 'This is a local executed command'"

    ; ~/.ssh/config
    ; Host alias
    ; HostName myserver.com
    ; User username
    ; IdentityFile ~/.ssh/mykey
    ; Usage: `ssh alias`
    ; Alternative: `ssh -i ~/.ssh/mykey username@myserver.com`

    ; Host deployment
    ; HostName github.com
    ; User username
    ; IdentityFile ~/.ssh/github_rsa
    ; Usage:
; git @deployment: username / anyrepo.git
    ; This is for cloning any repo that uses that IdentityFile.


    require("dotenv").config();

module.exports = {
    apps: [
        {
            name: process.env.NUXT_ENV_PROJECT_NAME,
            exec_mode: "cluster",
            instances: "max", // Or a number of instances
            script: "./node_modules/nuxt/bin/nuxt.js",
            args: "start",
            // cwd: "./current",
            windowsHide: true,
            max_memory_restart: "200M",
            log_date_format: "YYYY-MM-DD HH:mm Z",
            time: true,
        },
    ],

    // Deployment Configuration
    deploy: {
        production: {
            "user": "ubuntu",
            "host": ["3.75.148.238"],
            "ref": "release/release",
            "repo": "git@bitbucket.org:sigmaltd/ingotbrokers-website.git",
            "path": "/var/www/ingotbrokers-website",
            "post-deploy": "npm install"
        }
    }
};
