resource "random_id" "random_id_prefix" {
  byte_length = 2
}
/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "networking" {
  source = "./modules/networking"

  region               = var.region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = local.production_availability_zones
}
module "ec2" {
  source         = "./modules/ec2"
  count          = 1
  name           = "jenkins"
  instance_count = 1

  ami                    = "ami-ebd02392"
  instance_type          = "t2.micro"
  key_name               = "user1"
  monitoring             = true
  vpc_security_group_ids = module.networking.security_groups_ids
  subnet_id              = module.networking.private_subnets_id_1
  user_data              = <<-EOF
    #!/bin/bash
    sudo apt-get update
  EOF
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

