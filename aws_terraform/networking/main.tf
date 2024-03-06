########################################
        ##  Main File   ##
#######################################

provider "aws" {
  region                  = "eu-central-1"
  profile                 = "ingot"
}


module "networking" {

  # source = "github.com/??/aws_terraform-infra/networking" #local path or github repo
  source      =   "./networking"
  #optional 
  #private_database_subnets     = ["10.103.30.0/24", "10.103.31.0/24", "10.103.32.0/24"]
  #public_database_subnets      = ["10.103.40.0/24", "10.103.41.0/24", "10.103.42.0/24"]
  #private_k8s_subnets          = ["10.103.50.0/24", "10.103.51.0/24", "10.103.52.0/24"]
  #private_msk_subnets          = ["10.103.60.0/24", "10.103.61.0/24", "10.103.62.0/24"]
 
  tags = {
    Environment = "dev"
  }

  public_subnet_tags = {
    Tier = "public"
  }

  private_subnet_tags = {
    Tier = "private"
  }

  global_private_subnet_suffix="CORP"

  global_public_subnet_suffix ="DMZ" 

}
