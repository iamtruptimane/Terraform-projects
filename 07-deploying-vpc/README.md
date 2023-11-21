# Deploying an Amazon Virtual Private Cloud With Terraform

This main.tf file is a configuration file written in HashiCorp Configuration Language (HCL) used for defining and provisioning resources on AWS (Amazon Web Services) using Terraform, an infrastructure as code tool.

## Terraform Block
The terraform block defines the required providers for the configuration.
```
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "5.9.0"
        }
    }
}

```
This block specifies that the configuration requires the AWS provider from HashiCorp, with version 5.9.0.

## Provider Block
The provider block configures the AWS provider with specific settings.
```
provider "aws" {
    region = "us-west-2"
}

```
It sets the AWS region to us-west-2.

## Resource Block
The resource block creates an AWS Virtual Private Cloud (VPC) named demo_vpc.
```
resource "aws_vpc" "demo_vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "demo-vpc"
    }
}

```
It defines a VPC with the CIDR block 10.0.0.0/16 and assigns the tag Name = "demo-vpc" to it.

## Output Blocks
The output blocks define the outputs that Terraform will display after applying the configuration.

```
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

```
These outputs provide information about the VPC created:
* *id*:  Displays the ID of the VPC.
* *route_table_id*:  Displays the ID of the main route table associated with the VPC.
* *security_group_id*: Displays the ID of the default security group associated with the VPC.

This configuration, when executed with Terraform, will create an AWS VPC in the us-west-2 region with the specified CIDR block and associated tags. After provisioning, it will output the IDs of the VPC, main route table, and default security group.







