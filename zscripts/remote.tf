data "terraform_remote_state" "cluster" {

  backend = "s3"
  config = {
    bucket = format("tf-state-workshop-%s", var.tfid)
    region = data.aws_region.current.name
    key    = "terraform/terraform_locks_cluster.tfstate"
  }
}

data "terraform_remote_state" "iam" {

  backend = "s3"
  config = {
    bucket = format("tf-state-workshop-%s", var.tfid)
    region = data.aws_region.current.name
    key    = "terraform/terraform_locks_iam.tfstate"
  }
}
data "terraform_remote_state" "net" {

  backend = "s3"
  config = {
    bucket = format("tf-state-workshop-%s", var.tfid)
    region = data.aws_region.current.name
    key    = "terraform/terraform_locks_net.tfstate"
  }
}


data "terraform_remote_state" "tf-setup" {
  backend = "s3"
  config = {
    bucket = format("tf-state-workshop-%s", var.tfid)
    region = data.aws_region.current.name
    key    = "terraform/terraform_locks_tf-setup.tfstate"
  }
}

