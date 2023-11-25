# Creating AWS Resources with Terraform

## Project description
Terraform is a tool for declaring and managing infrastructure as code. With Terraform you can write declarative configuration files, view execution plans, and apply plans to realize the infrastructure declared in the configuration files. An important advantage of Terraform is that is supports over 100 resource providers including the major public cloud providers, such as Amazon Web Services, Microsoft Azure, and Google Cloud Platform. In this Lab, you will learn the basics of working with Terraform and create an Amazon Virtual Private Cloud (VPC) with Terraform.

## Project Objectives
* Install Terraform on Linux
* Configure Terraform providers
* Create AWS resources with Terraform

## Project Prerequisites
* Working at the command-line in Linux
* Amazon VPC basics 

## Step 1: Login to your AWS account.
Go to your AWS account and login with your credentials.

## Step 2: Create an EC2 instance.
refere this link to create an EC2 instance.
[create an EC2 instance](https://github.com/iamtruptimane/create-an-EC2-instance)

## Step 3: Connect to the EC2 instance through EC2 instance connect.
connect to the EC2 instance by clicking on connect button with EC2 instance connect.

## Step 4:Installing Terraform

1. Download a release package:
```
wget https://releases.hashicorp.com/terraform/1.0.1/terraform_1.0.1_linux_amd64.zip
```
2. Extract the zip archive containing the Terraform binary to the /usr/local/bin directory:
```
sudo unzip terraform_1.0.1_linux_amd64.zip -d /usr/local/bin/
```
/usr/local/bin is included in the PATH environment variable allowing you to run terraform from any directory.

3. Remove the release package:
```
rm terraform_1.0.1_linux_amd64.zip
```
4. Confirm Terraform version 1.0.1 is installed:
```
terraform version
```
## Step 5: Configuring Providers in Terraform
1. Make a directory for organizing your Terraform configuration, and change into it:
```
mkdir infra && cd infra
```
2. Create a Terraform configuration file declaring the AWS provider:
```
cat > main.tf <<EOF
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
EOF
```
3. Initialize the working directory by running the init command:


```
terraform init
```

4. List all of the directories to see what the init command has created:
```
ls -A
```
The .terraform directory stores the downloaded AWS provider plugin in .terraform/providers/registry.terraform.io/hashicorp/
aws/3.48.0/linux_amd64/

## Step 5: Creating an AWS Resource with Terraform

1. Append an aws_vpc resource block to your main.tf Terraform configuration file:
```
cat >> main.tf <<EOF
resource "aws_vpc" "web_vpc" {
  cidr_block = "192.168.100.0/24"
  enable_dns_hostnames = true
  tags = {
    Name = "Web VPC"
  }
}
EOF
```
2. Issue the apply command to have Terraform generate a plan that you can review before actually applying:
```
terraform apply
```

The Terraform plan is output and indicates the number of resources to add, change, or destroy. The plan details use the following symbols for each type of action:
* +: Add
* -: Destroy
* ~: Change

3. Accept and apply the execution plan by entering yes at the prompt.

4. Use the AWS command-line interface (CLI) to confirm that the VPC has been created with the arguments you specified:
```
aws ec2 describe-vpcs --region us-west-2 --filter "Name=tag:Name,Values=Web VPC"
```

5. Enter the following command to determine if DNS hostnames support is enabled for the VPC:
```
aws ec2 describe-vpc-attribute --region us-west-2 --attribute enableDnsHostnames --vpc-id <VPC_ID>
```




