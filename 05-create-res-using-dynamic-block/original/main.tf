terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.9.0"
    }
  }
}

provider "aws" {
    region = "us-west-2"
}

resource "aws_vpc" "demo-vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
      Name = "demo-vpc"
    } 
}

resource "aws_security_group" "web-sg" {
    vpc_id = aws_vpc.demo-vpc.id
    name = "web-sg"
    description = "AWS Security Group for webserver"

    ingress {
        protocol = "tcp"
        from_port = 80
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        protocol = "tcp"
        from_port = 443
        to_port = 443
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
  
}