provider "aws" {
  region = var.aws_region
}
/*
terraform {
  backend "s3" {
    bucket         = "memo-bucket-21-12-2024"  # Your bucket name
    key            = "terraform.tfstate"
    region         = "us-east-1"               # Your region
    dynamodb_table = "memo-table-21-12-2024"  # "terraform-state-lock"    # Your DynamoDB table name
    encrypt        = true
  }
}
*/


module "backend" {
  source             = "./modules/backend"
  state_bucket_name        = var.state_bucket_name
  dynamodb_table_name = var.dynamodb_table_name
}

module "vpc" {
  source            = "./modules/vpc"
  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.subnet_cidr
  availability_zone = var.availability_zone
}

module "jenkins_server" {
  source            = "./modules/ec2"
  ami_id            = var.ami_id
  instance_type     = "t2.small"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.vpc.jenkins_sg_id
  key_name          = var.key_name
  instance_name     = "jenkins-server"
}

module "slave_tools" {
  source            = "./modules/ec2"
  ami_id            = var.ami_id
  instance_type     = "t3.large"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.vpc.sonarqube_sg_id
  key_name          = var.key_name
  instance_name     = "slave-tools"
}

module "jenkins_monitoring" {
  source        = "./modules/monitoring"
  instance_id   = module.jenkins_server.instance_id
  instance_name = "jenkins-server"
  aws_region    = var.aws_region
}

module "slave_monitoring" {
  source        = "./modules/monitoring"
  instance_id   = module.slave_tools.instance_id
  instance_name = "slave-tools"
  aws_region    = var.aws_region
}

resource "local_file" "ansible_inventory" {
  content = <<-EOT
    [jenkins]
    ${module.jenkins_server.public_dns}

    [tools]
    ${module.slave_tools.public_dns}
  EOT
  filename = "../ansible/inventory"
}

