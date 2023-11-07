# Terraform-projects
## Create an EC2 instance on AWS using either Terraform or CloudFormation. The instance should include a user data startup script that sets up Ansible on the EC2 instance.
# Step 1. Create the main.tf file  
### First, add the provider code to ensure you use the AWS provider.
``` 
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
} 
```  
# Step 2. Next, set up your Terraform resource, which describes an infrastructure object, for the EC2 instance.  This will create the instance.   
```
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
```  
# Step 3. Create the EC2 environment  
## To deploy the EC2 environment, ensure you're in the Terraform module/directory in which you write the Terraform code, and run the following commands:  
- terraform init. Initializes the environment and pulls down the AWS provider.  
- terraform plan. Creates an execution plan for the environment and confirm no bugs are found.  
- terraform apply --auto-approve. Creates and automatically approves the environment.  
# Step 4. Clean up the environment  
## To destroy all Terraform environments, ensure that you're in the Terraform module/directory that you used to create the EC2 instance and run terraform destroy.