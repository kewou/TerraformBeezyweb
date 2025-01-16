terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-3"
}

module "ec2_with_dns" {
  source = "../modules/terraform-ec2-route53"
  ami                  = "ami-0ba66558fb9b005b1"
  instance_type        = "t2.micro"
  key_name             = "beezyKey"
  subnet_id            = "subnet-023854c2c845b28e7"
  security_groups      = ["sg-06b28823183ebfdbf"]
  instance_name        = "Backend-Instance-EC2"
  domain_name          = "beezyweb.net"
  route53_record_name  = "api.beezyweb.net"
}
