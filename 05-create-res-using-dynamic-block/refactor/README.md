This Terraform script is designed to create an AWS VPC along with a corresponding security group using a more structured approach with the use of locals and dynamic blocks for defining ingress and egress rules.

## Provider Configuration
```
provider "aws" {
  region = "us-west-2"
}

```
Specifies the AWS provider to be used and sets the region to us-west-2.

## Locals
```
locals {
  sg_name        = "web-sg"
  sg_description = "AWS security group for webserver"
  vpc_cidr       = "10.0.0.0/16"
  tags = {
    Name = "demo-vpc"
  }
  ingress_rules = [  # Define ingress rules using a list of objects
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
      cidr_blocks = [local.vpc_cidr]  # Using local variable to reference VPC CIDR
    }
  ]
  egress_rules = [  # Define egress rules using a list of objects
    {
      port        = 0,
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

```
Sets up local variables to define the security group name, description, VPC CIDR block, tags for resources, and separate lists of ingress and egress rules for the security group.

## Resources
```
resource "aws_vpc" "demo-vpc" {
  cidr_block = local.vpc_cidr

  tags = local.tags
}

```
Creates an AWS VPC named "demo-vpc" with the specified CIDR block and tags.

```
resource "aws_security_group" "sg-webserver" {
  vpc_id      = aws_vpc.demo-vpc.id  # References the created VPC
  name        = local.sg_name
  description = local.sg_description

  dynamic "ingress" {
    for_each = local.ingress_rules  # Dynamically generates ingress rules based on the local variable
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules  # Dynamically generates egress rules based on the local variable
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

```
Creates an AWS security group named "web-sg" for the VPC with dynamically generated ingress and egress rules based on the predefined local variables. It uses dynamic blocks to iterate through the lists of rules and generate the required rules for the security group.

This structured approach makes it easier to manage and modify rules by defining them in a more organized manner using local variables, especially when dealing with multiple rules or frequent changes to rulesets.






