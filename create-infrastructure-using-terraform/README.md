# Terraform AWS Infrastructure Deployment

This Terraform script deploys a basic AWS infrastructure consisting of a Virtual Private Cloud (VPC), two subnets, an Internet Gateway, a Route Table, a Security Group, two EC2 instances, an Application Load Balancer (ALB), and associated resources. The ALB distributes traffic between the two EC2 instances.

## Prerequisites

Before running this Terraform script, ensure you have the following:

1. [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
2. AWS credentials configured with appropriate permissions.

## Usage

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/iamtruptimane/Terraform-projects.git

2. Navigate to the project directory:
```
cd create-infrastructure-using-terraform

```  

3. Initialize the terraform project:
```
terraform init

```
4. Modify variables.tf to set any custom variables, such as cidr or ami IDs, if needed.
   
5. Apply terraform configration:
```
terraform apply

```
This command will prompt you to confirm the planned changes. Type yes to proceed.

# Resources Created:
* ## aws_vpc.myvpc 
   This resource creates a Virtual Private Cloud (VPC) with the specified CIDR block.

* ## aws_subnet.sub1 and aws_subnet.sub2     
  These resources create two subnets within the VPC. They are associated with availability zones use1-az1 and use1-az2 respectively, and have public IP mapping enabled.

* ## aws_internet_gateway.igw    
  This resource creates an Internet Gateway and attaches it to the VPC. 

* ## aws_route_table.RT   
    This resource creates a route table associated with the VPC. It has a default route pointing to the Internet Gateway. 

* ## aws_route_table_association.rta1 and aws_route_table_association.rta2
    These resources associate the created route table with the corresponding subnets (sub1 and sub2). 

* ## aws_security_group.webSg  
  This resource creates a security group named web allowing inbound traffic on ports 80 (HTTP) and 22 (SSH) from any source.

* ## aws_s3_bucket.example
  This resource creates an S3 bucket named truptiterraform2023project.

* ## aws_instance.webserver1 and aws_instance.webserver2
     These resources create two EC2 instances using the specified AMI and instance type. They are associated with the corresponding security group and subnet.  

* ## aws_lb.mylb
    This resource creates an Application Load Balancer (ALB) named mylb. It is associated with the specified security group and subnets. 

* ##  aws_lb_target_group.tg 
   This resource creates a target group named myTG for the ALB, listening on port 80 and using HTTP protocol.

* ## aws_lb_target_group_attachment.attach1 and aws_lb_target_group_attachment.attach2
    These resources attach the EC2 instances to the target group.

* ## aws_lb_listener.listner
  This resource creates a listener on the ALB, forwarding traffic to the target group.

#  Outputs:
Terraform will now create the AWS resources. You can monitor the progress in the console output.
* ## loadbalancerdns
   This output displays the DNS name of the ALB.

# Access the Resources
Once the deployment is complete, you can access the resources created:  
* EC2 Instances: Connect to them using SSH.
* Load Balancer: Access it using the provided DNS name. 
    

# Clean Up
 To destroy the created resources, run:
 ```
 terraform destroy

 ```  
This will prompt you to confirm the destruction of the resources. Type yes to proceed.                         