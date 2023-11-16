terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.9.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Locals

locals {
  sg_name        = "web-sg"
  sg_description = "AWS security group for webserver"
  vpc_cidr       = "10.0.0.0/16"
  tags = {
    Name = "demo-vpc"
  }
  ingress_rules = [
    {
      port        = 80,
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 443,
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 22,
      protocol    = "tcp"
      cidr_blocks = [local.vpc_cidr]
    }
  ]
  egress_rules = [
    {
      port        = 0,
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

# Resources

resource "aws_vpc" "demo-vpc" {
  cidr_block = local.vpc_cidr

  tags = local.tags
}

resource "aws_security_group" "sg-webserver" {
  vpc_id      = aws_vpc.lab_vpc.id
  name        = local.sg_name
  description = local.sg_description

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
