##==============================
## Building EC2 Instance


build {

sources=["source.amazon-ebs.Zabbix"]

  provisioner "shell" {
    inline = [
      "sudo apt update --yes",
      "sudo apt dist-upgrade --yes -qq"
    ]
    pause_before = "10s"
    max_retries = 5
    timeout = "5m"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt install --yes -qq apt-transport-https lsb-release ca-certificates software-properties-common curl wget apt-utils git iputils-ping libicu-dev gnupg",
      "sudo apt autoclean",
      "sudo apt-get update -y",
      #"sudo rm -rf /var/lib/apt/lists/*",
      #"sudo rm -rf /var/log/*"
    ]
    pause_before = "10s"
    max_retries = 5
    timeout = "5m"
  }

  provisioner "shell" {
    inline = ["echo \"Runnning Docker Installation Script\""]
  }

  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/ubuntu"
    ]
    execute_command   = "{{.Vars}} sudo -S -E bash -eux '{{.Path}}'"
    expect_disconnect = true
    script = "./install_docker.sh"
  }

  //provisioner "shell" {
  //  scripts=[
  //   "{{ template_dir }}install-cassandra.sh"
  //     ]
  //  }
}
