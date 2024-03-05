

build {
    sources = [
        "source.amazon-ebs.standard",
        "source.amazon-ebs.unlimited"
    ]
    provisioner "shell" {
        inline = [
            "echo provisioning all the things",
            "sudo apt-get install -q -y '${var.pkg}' jq"
        ]
        pause_before = "10s"
        max_retries = 5
        timeout = "5m"
    }
    # This provisioner only runs for the 'first-example' source.

    provisioner "shell" {
        only = ["amazon-ebs.standard"]
        inline = [
            "aws configure set region ${var.region} --profile default",
            "CREDITTYPE=$(aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID}| jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\")",
            "echo CPU Credit Specification is $CREDITTYPE",
            "[[ $CREDITTYPE == ${var.standardCPUCredit} ]]"
        ]
    }

    provisioner "shell" {
        environment_vars  = [ "HOME_DIR=/home/vagrant" ]
        execute_command   = "echo 'vagrant' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
        expect_disconnect = true
         // fileset will list files in etc/scripts sorted in an alphanumerical way.
        scripts           = fileset(".", "etc/scripts/*.sh")
    }

    provisioner "shell" {
		only = ["amazon-ebs.unlimited"]
		inline = ["TOKEN=`curl -s -X PUT \"http://169.254.169.254/latest/api/token\" -H \"X-aws-ec2-metadata-token-ttl-seconds: 21600\"` && curl -H \"X-aws-ec2-metadata-token: $TOKEN\" -s http://169.254.169.254/latest/meta-data/"]
		script = "./${path.root}/010-update,sh"
		environment_vars = ["USER=packeruser", "BUILDER=${upper(build.ID)}"]
	}

    provisioner "shell" {
        only = ["amazon-ebs.standard"]
        inline = [
            "aws configure set region ${var.region} --profile default",
            "CREDITTYPE=$(aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID}| jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\")",
            "echo CPU Credit Specification is $CREDITTYPE",
            "[[ $CREDITTYPE == ${var.standardCPUCredit} ]]"
        ]
    }  

    provisioner "shell" {
        environment_vars = [
            EPO_URL="https://download.docker.com/linux/${DIST_ID}",
            ARCH="$( dpkg --print-architecture )"
        ]
        only = ["amazon-ebs.standard"]
        inline = [
            "echo Installing Docker",
            "sleep 30",
            "sudo apt-get update",
            "echo ",
            "echo '[DEBUG] Installing engine dependencies from ${REPO_URL}'",
            "sudo update-ca-certificates -f",
            "curl -fsSL "${REPO_URL}/gpg" | apt-key add -",
            "echo "deb [arch=${ARCH}] ${REPO_URL} ${DIST_VERSION} test" > /etc/apt/sources.list.d/docker.list",
            "sudo apt-get update"
        ]

        timeout = "5m"
        max_retries = 5
    }

    provisioner "shell" {
        only = ["amazon-ebs.unlimited"]
        inline = [
            "aws configure set region ${var.region} --profile default",
            "CREDITTYPE=$(AWS_DEFAULT_REGION=us-west-2 aws ec2 describe-instance-credit-specifications --instance-ids ${build.ID} | jq --raw-output \".InstanceCreditSpecifications|.[]|.CpuCredits\")",
            "echo CPU Credit Specification is $CREDITTYPE",
            "[[ $CREDITTYPE == ${var.unlimitedCPUCredit} ]]"
        ]
    }
}

