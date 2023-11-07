terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }

}
provider "aws" {
  region     = "us-east-1"
  access_key = "ADD_YOUR_ACCESS_KEY"
  secret_key = "ADD_YOUR_SECRET_KEY"

}

resource "aws_instance" "web_server" {
    ami = "ami-01bc990364452ab3e" 
    instance_type = "t2.micro"
    tags = {
        name = "Terraform-server"
    }
    user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install ansible2 -y
              EOF

}