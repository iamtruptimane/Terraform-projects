# Deploy a Highly Available Website with Terraform on AWS
An attractive feature of the cloud is that you can deploy applications in multiple data centers making them highly available and able to tolerate a high degree of failures. In this project, we will deploy a secure and highly available website with Terraform on AWS using a two-tier architecture with private and public subnets. The web servers and Elastic Load Balancer will span multiple availability zones to achieve high availability.

## Project Objectives
* Apply infrastructure changes in Terraform
* Configure all the network and security infrastructure needed to deploy a highly available website
* Use user data to bootstrap web servers
* Destroy infrastructure managed by Terraform

#### **NOTE** : _Before starting this project reference the resources that are created in the following terraform projects_ :
1. [03-create-aws-res-using-terraform](/03-create-aws-res-using-terraform/) 
2. [04-manage-aws-resources](/04-manage-aws-resources/) 

## Step 1:Logging In to the Amazon Web Services Console
login to the Amazon Web Services Console using your credentials.

## Step 2 : create an EC2 instance
To create an EC2 instance using AWS console reference the following project:

[create an EC2 instance](https://github.com/iamtruptimane/create-an-EC2-instance)

## Step 3 : Connecting to the Virtual Machine using EC2 Instance Connect.
connect to the EC2 instance by clicking on connect button with EC2 instance connect.


## Step 4 : Configuring the Website on the EC2 Instances with Terraform
In this Step we will modify the existing configuration [main.tf file](/04-manage-aws-resources/main.tf) to configure the instances to serve a website. For demonstration purposes, the website is a simple web page that echoes back the instance ID of the EC2 instance that served the request.

1. Change into the Terraform working directory called infra:
```
cd infra
```
2. List the resources currently managed by Terraform:
```
terraform state list
```
There is a VPC, two subnets, and two instances. The subnets are private, i.e. they don't have a route to the internet. The instances are running the Apache web server and a default web page is being served.

3. Remove the current instance configuration in the main.tf file:
```
sed -i '/.*aws_instance.*/,$d' main.tf
```
This command deletes all the lines from the file starting from the line matching aws_instance. The instance configuration is the last block in the file so all the other configuration is preserved.

4. Append the following resource block to configure the instances to serve a custom website that echoes back the instance's ID:
```
cat >> main.tf <<'EOF'
resource "aws_instance" "web" {
  count         = "${var.instance_count}"
  # lookup returns a map value for a given key
  ami           = "${lookup(var.ami_ids, "us-west-2")}"
  instance_type = "t2.micro"
  # Use the subnet ids as an array and evenly distribute instances
  subnet_id     = "${element(aws_subnet.web_subnet.*.id, count.index % length(aws_subnet.web_subnet.*.id))}"
  
  # Use instance user_data to serve the custom website
  user_data     = "${file("user_data.sh")}"
  
  tags {
    Name = "Web Server ${count.index + 1}"
  }
}

EOF
```
5. Create the user_data.sh script that will create and serve the custom website:
```
cat >> user_data.sh <<'EOF'
#!/bin/bash
cat > /var/www/html/index.php <<'END'
<?php
$instance_id = file_get_contents("http://instance-data/latest/meta-data/instance-id");
echo "You've reached instance ", $instance_id, "\n";
?>
END
EOF
```
The script creates a file called index.php in the default serving directory of the Apache web server. The PHP code gets the instance ID from the instance's metadata and echoes it back to the user.

6. View the execution plan for the configuration change, and enter yes when prompted:
```
terraform apply
```
The plan tells you that Terraform must destroy and then create replacement instances. This is because the user_data must be executed when an instance is first launched. Many changes to instance configuration don't require recreation. Terraform would notify you of an update in-place in the execution plan when recreation isn't required. The operation should complete in under one minute.

## Step 5: Configuring Network Resources for Elastic Load Balancing with Terraform
You now have two instances serving your custom website. The instances are running in private subnets in different availability zones and are assigned to the default security group for the VPC that allows all traffic. There are a few resources that need to be created to allow for an Elastic Load Balancer (ELB) to securely distribute traffic between the instances:
* Public subnets for each availability zone must be created so the load balancer can be accessed from the internet.
    * This requires additional resources such as an internet gateway to connect to the internet, and route tables that route to the internet
* A security group to allow traffic from the internet to the public subnets that will house the ELB on port 80 (HTTP)
* A security group to allow traffic from the ELB in the public subnets to the instances in the private subnets on port 80 (HTTP)

we will make use of separate configuration files to make the configuration more manageable.

1. Create the required networking resources for public subnets in a configuration file named networking.tf:
```
cat > networking.tf <<'EOF'
# Internet gateway to reach the internet
resource "aws_internet_gateway" "web_igw" {
  vpc_id = "${aws_vpc.web_vpc.id}"
}
# Route table with a route to the internet
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.web_vpc.id}"
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.web_igw.id}"
  }
  tags {
    Name = "Public Subnet Route Table"
  }
}
# Subnets with routes to the internet
resource "aws_subnet" "public_subnet" {
  # Use the count meta-parameter to create multiple copies
  count             = 2
  vpc_id            = "${aws_vpc.web_vpc.id}"
  cidr_block        = "${cidrsubnet(var.network_cidr, 2, count.index + 2)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  tags {
    Name = "Public Subnet ${count.index + 1}"
  }
}
# Associate public route table with the public subnets
resource "aws_route_table_association" "public_subnet_rta" {
  count          = 2
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
EOF
```
2. Execute the plan to create the networking resources:
```
terraform apply
```
3. Create the security groups that will secure traffic into the public and private subnets in a configuration file called security.tf:
```
cat > security.tf <<'EOF'
resource "aws_security_group" "elb_sg" {
  name        = "ELB Security Group"
  description = "Allow incoming HTTP traffic from the internet"
  vpc_id      = "${aws_vpc.web_vpc.id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "web_sg" {
  name        = "Web Server Security Group"
  description = "Allow HTTP traffic from ELB security group"
  vpc_id      = "${aws_vpc.web_vpc.id}"
  # HTTP access from the VPC
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb_sg.id}"]
  }
  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
EOF
```
4. Apply the configuration changes to create the security groups:
```
terraform apply
```
5. Remove the current instance configuration in the main.tf file so you can modify the configuration to attach the web server security group to them:
```
sed -i '/.*aws_instance.*/,$d' main.tf
```
6. Append the following resource block to configure the instances to serve a custom website that echoes back the instance's ID:
```
cat >> main.tf <<'EOF'
resource "aws_instance" "web" {
  count                  = "${var.instance_count}"
  # lookup returns a map value for a given key
  ami                    = "${lookup(var.ami_ids, "us-west-2")}"
  instance_type          = "t2.micro"
  # Use the subnet ids as an array and evenly distribute instances
  subnet_id              = "${element(aws_subnet.web_subnet.*.id, count.index % length(aws_subnet.web_subnet.*.id))}"
  
  # Use instance user_data to serve the custom website
  user_data              = "${file("user_data.sh")}"
  
  # Attach the web server security group
  vpc_security_group_ids = ["${aws_security_group.web_sg.id}"]
  tags { 
    Name = "Web Server ${count.index + 1}" 
  }
}
EOF
```
The only difference from the previous configuration is the addition of vpc_security_group_ids.

7. Apply the configuration change:
```
terraform apply
```
This change doesn't require recreation and an update in-place can be performed.

In this Step, we created two additional configuration files to manage network and security resources for the public and private subnets. The public subnets will house the ELB that you create in the next Lab Step. The public subnet security group allows incoming HTTP traffic from the internet, and the private subnet security group allows incoming HTTP traffic from the ELB public subnet security group.

## Step 6: Configuring an Elastic Load Balancer with Terraform
we have completed the private tier of the website infrastructure and we have two public subnets and a security group for an ELB. In this step Step, we will complete the scenario by adding a cross-zone ELB to distribute traffic to the web servers running in the private subnets. The website will then be highly available since the ELB will allow you to continue serving the website while one instance is down.

1. Create an ELB configuration in a file named load_balancer.tf:
```
cat > load_balancer.tf <<'EOF'
resource "aws_elb" "web" {
  name = "web-elb"
  subnets = ["${aws_subnet.public_subnet.*.id}"]
  security_groups = ["${aws_security_group.elb_sg.id}"]
  instances = ["${aws_instance.web.*.id}"]

  # Listen for HTTP requests and distribute them to the instances
  listener { 
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # Check instance health every 10 seconds
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 10
  }
}

EOF
```
2. Add an output that will save the DNS address of the ELB as the website address:
```
cat >> outputs.tf <<'EOF'
output "site_address" {
  value = "${aws_elb.web.dns_name}"
}

EOF
```
3. Apply the configuration changes:
```
terraform apply
```
4. Store the site_address output in a shell variable:
```
site_address=$(terraform output site_address)
```
5. Send an HTTP request to the ELB every two seconds using the watch and curl command:
```
watch curl -s $site_address
```
It takes about a minute for the ELB to start sending requests to the instances. You will eventually see messages from the web server instances and you should notice the instance ID changing between two values. This verifies the ELB is distributing the traffic to all of the instances.

6. Press ctrl+c to stop the watch command..

In this Step, we configured a cross-zone Elastic Load Balancer in the public subnets of our infrastructure. The load balancer distributes traffic to the web server instances in the private subnets of our infrastructure. we used an output to conveniently access the DNS name of the load balancer.

## Step 7: Destroying Resources with Terraform
1. Delete the ELB security group using the destroy command and the target option, and enter yes to accept the plan:
```
terraform destroy -target=aws_security_group.elb_sg
```
To destroy the target resource, all the resources that depend on the target must also be destroyed. 

2. Run the plan command to verify that destroying resources doesn't affect your desired configuration:
```
terraform plan
```
The plan is to add back the resources you just destroyed. This may be what you want if a resource is modified outside of Terraform and it can't be brought back to the desired state requiring you to destroy and recreate it. If you actually no longer need a resource, you should remove it from the configuration.

3. Destroy all the remaining resources managed by Terraform, and enter yes when prompted:
```
terraform destroy
```
In this  Step, we learned how to destroy resources managed by Terraform. we used both flavors of destroy: destroying specific targets, and destroying all resources managed by Terraform.
































