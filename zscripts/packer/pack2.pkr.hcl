provider "docker" {}

resource "docker_image" "myenginxapp" {
  name         = "nginx:latest"
  keep_locally = false
}


docker = {
      version = ">= 1.0.8"
      source = "github.com/hashicorp/docker"
    }
	
	
//resource "docker_image" "nginxlatest" {
//  name            =  nginx_app
//  image           = "nginx:latest"
//  commit          = true
//  keep_locally    = false
//}


//resource "docker_container" "nginx_container" {
//  image = docker_image.nginxlatest
//  name  = "tfe-nginx"
//  ports {
//    internal = 80
//    external = 8000
///  }
//}
#source "docker" "ubuntu" {
#  image  = "ubuntu:jammy"
#
#}

 //"source.docker.nginxlatest"
 
 
 
  # This provisioner only the second for the source.
  //provisioner "shell-local" {
  //  environment_vars      = ["HOME=/home/${var.ssh_user}"]
  //  execute_command       = "$HOME/docker-compose up -d > /dev/null"
  //  expect_disconnect     = true
  //  scripts               = fileset(".", "$HOME/*.yaml")
  //}
  
  
  //provisioner "shell" {
  //  environment_vars    = ["HOME_DIR=/home/ubuntu"]
  //  execute_command     = "echo 'ubuntu' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
  //  scripts             = fileset("./", "docker/install_docker.sh")
  //  expect_disconnect   = true
  //}
  
  
  




  #post-processor "manifest" {
  #  output         = "result.txt"
  #  strip_path     = true
  #}
