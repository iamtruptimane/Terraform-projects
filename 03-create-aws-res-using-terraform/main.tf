terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.48.0"
    }
  }  
}
provider "aws" {
  region = "us-west-2" # Oregon
}
resource "aws_vpc" "web_vpc" {
  cidr_block = "192.168.100.0/24"
  enable_dns_hostnames = true
  tags = {
    Name = "Web VPC"
  }
}