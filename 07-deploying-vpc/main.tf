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

    resource "aws_vpc" "demo_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "demo-vpc"
    }
    }

    output "id" {
    description = "VPC ID"
    value       = aws_vpc.demo_vpc.id
    }
    output "route_table_id" {
    description = "Route Table ID associated with this VPC"
    value       = aws_vpc.demo_vpc.main_route_table_id
    }
    output "security_group_id" {
    description = "Default Security Group ID"
    value       = aws_vpc.demo_vpc.default_security_group_id
    }

