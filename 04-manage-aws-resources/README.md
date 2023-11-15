# Manage AWS Resources with Terraform
## Lab Overview
Terraform allows you to safely manage your infrastructure by modifying configuration files. Terraform will show you an execution plan that you must approve before any infrastructure changes are applied. This Lab highlights several capabilities of Terraform that make managing infrastructure easy. You will learn how to import existing resources, understand configuration file interpolation syntax to reference resource attributes, and use variables to generalize configuration while you manage AWS resources with Terraform. 

## Lab Objectives
* Import existing resources into Terraform
* Use interpolation syntax to reference resource attributes in configurations
* Use variables to parameterize Terraform configurations
* Understand Terraform's concept of state

## Lab Prerequisites
* Working at the command-line in Linux
* Amazon VPC and EC2 basics

# Step 1: Login to your AWS account.
Go to your AWS account and login with your credentials.

## Step 2: Create an EC2 instance.
search EC2 service and create an EC2 instance.

## Step 3: Connect to the EC2 instance through EC2 instance connect.
connect to the EC2 instance by clicking on connect button with EC2 instance connect.

## Step 4: Importing an AWS Resource into Terraform
Terraform keeps track of the infrastructure it manages by maintaining state. The state information contains what is needed to map between real-world infrastructure and configuration files along with other metadata.When you create resources with Terraform, the state is automatically maintained. But you can also import existing infrastructure so that it can be managed by Terraform. 

In this  Step, you will use the import command to bring an existing VPC under the control of Terraform and verify its addition to the Terraform state.

1. Change into the infra directory which includes a Terraform configuration and initialized working directory:
```
cd infra
```
2. List all the files in the directory:
```
ls -A
```
The listing has two entries:
* main.tf: A Terraform configuration file
* .terraform: A directory created by the init command that includes the AWS Terraform provider plugin

Also, observe that there is no terraform.tfstate file, indicating that Terraform is not currently managing any resources.

3. View the contents of the main.tf configuration file:
```
cat main.tf 
```
4. Use the AWS command-line interface (CLI) to verify that a VPC with the Name tag set to Web VPC already exists:
```
aws ec2 describe-vpcs --region us-west-2 --filter "Name=tag:Name,Values='Web VPC'"
```
5. Import the VPC into Terraform's state
```
terraform import aws_vpc.web_vpc vpc-0e7e70ab1010ae2f1

```

6. List the files in the current directory:
```
ls
```
Terraform has created the terraform.tfstate file to keep track of the resource it has imported.

## Summary
In this Lab Step, you learned about Terraform state and imported an existing resource into Terraform's state. Importing is useful for migrating existing resources to be managed by Terraform. Imported resources should be managed exclusively by Terraform and not modified outside of Terraform. For example, modifying the Web VPC in the AWS portal would create an inconsistency between the state stored by Terraform and the actual resource. Terraform will update the state whenever you use apply, detect the change, and modify the resource to bring it back to the desired state described in the configuration.

## Step 5: Creating an EC2 Instance with Terraform
In this Lab Step, you will create an EC2 instance inside of the VPC managed by Terraform. You will also create subnets as a requirement for creating an EC2 instance in a VPC. In doing so, you will become familiar with two features of Terraform configuration:
* Interpolation syntax, and
* Implicit dependencies.

1. Add a couple of subnets to the Terraform configuration:
```
cat >> main.tf <<'EOF'
resource "aws_subnet" "web_subnet_1" {
  vpc_id            = "${aws_vpc.web_vpc.id}"
  cidr_block        = "192.168.100.0/25"
  availability_zone = "us-west-2a"
  tags {
    Name = "Web Subnet 1"
  }
}
resource "aws_subnet" "web_subnet_2" {
  vpc_id            = "${aws_vpc.web_vpc.id}"
  cidr_block        = "192.168.100.128/25"
  availability_zone = "us-west-2b"
  tags {
    Name = "Web Subnet 2"
  }
}
EOF
```
The subnets vpc_id argument use interpolation syntax to obtain the Web VPC ID.

2. Add an EC2 instance to the first subnet in the configuration:
```
cat >> main.tf <<'EOF'
resource "aws_instance" "web" {
  ami           = "ami-0fb83677"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.web_subnet_1.id}"
  
  tags {
    Name = "Web Server 1"
  }
}
EOF
```
The subnet_id is set using interpolation syntax to the ID of the first web subnet. Terraform is able to determine the order it needs to create the resources to be able to use the interpolate the values. Particularly, web_subnet_1 must be created before web, and web_vpc must be created before both web_subnet_1 and web_subnet_2.

3. Plan and apply the changes using the apply command:
```
terraform apply
```

Note that the first action Terraform takes is to Refreshing state. That is so Terraform can detect if the VPC resource has diverged from the desired state described in the configuration. In this case, the actual state matches the desired state for the VPC resource and no changes are required. After that, three resources that will be added are listed. 

4. Enter yes to accept the execution plan, and create the resources.

Observe the order that the resources were created in and verify they follow the implicit dependencies in the configuration file.

## Summary
In this Lab Step, you created an EC2 instance using Terraform. You learned how to use interpolation syntax in a Terraform configuration file to reference resource attributes and implicitly create dependencies between resources. You also observed the dependency graph generated by the graph command.

## Step 6: Using Variables to Generalize Terraform Configuration
You have seen how interpolation can access resource attributes inside of a configuration. Another use case of interpolation is accessing input variables. You can define variables in the same configuration file, by passing them as command-line arguments, by entering them interactively when running the apply command, using environment variables, or in variable files. In this step we uses a separate variable file because having separate variable files keep the configuration organized and are easy to version control.

1. Delete the configuration changes you made in the last Lab Step:
```
sed -i '/.*web_subnet_1.*/,$d' main.tf
```
This deletes all the lines in the configuration file starting from the line that declares web_subnet_1.

2. Apply the configuration changes to realize the new desired state with the subnets and instance removed, and enter yes when prompted:
```
terraform apply
```
3. Create a variable file named variables.tf:
```
cat > variables.tf <<'EOF'
# Example of a string variable
variable network_cidr {
  default = "192.168.100.0/24"
}

# Example of a list variable
variable availability_zones {
  default = ["us-west-2a", "us-west-2b"]
}

# Example of an integer variable
variable instance_count {
  default = 2
}

# Example of a map variable
variable ami_ids {
  default = {
    "us-west-2" = "ami-0fb83677"
    "us-east-1" = "ami-97785bed"
  }
}

EOF
```
The default value for each variable is used unless overridden.

4. Add the following configuration that uses the variables to dynamically create subnet and instance resources:
```
cat >> main.tf <<'EOF'
resource "aws_subnet" "web_subnet" {
  # Use the count meta-parameter to create multiple copies
  count             = 2
  vpc_id            = "${aws_vpc.web_vpc.id}"
  # cidrsubnet function splits a cidr block into subnets
  cidr_block        = "${cidrsubnet(var.network_cidr, 1, count.index)}"
  # element retrieves a list element at a given index
  availability_zone = "${element(var.availability_zones, count.index)}"

  tags {
    Name = "Web Subnet ${count.index + 1}"
  }
}

resource "aws_instance" "web" {
  count         = "${var.instance_count}"
  # lookup returns a map value for a given key
  ami           = "${lookup(var.ami_ids, "us-west-2")}"
  instance_type = "t2.micro"
  # Use the subnet ids as an array and evenly distribute instances
  subnet_id     = "${element(aws_subnet.web_subnet.*.id, count.index % length(aws_subnet.web_subnet.*.id))}"
  
  tags {
    Name = "Web Server ${count.index + 1}"
  }
}

EOF
```
The count metaparameter allows you to create multiple copies of a resource. Interpolation using count.index allows you to modify the copies. index is zero for the first copy, one for the second, etc. For example, the instances are distributed between the two subnets that are created by using count.index to select between the subnets. There is no duplication between resources compared to the configuration in the last Lab Step.

5. Create an output variable file called outputs.tf that 
```
cat > outputs.tf <<'EOF'
output "ips" {
  # join all the instance private IPs with commas separating them
  value = "${join(", ", aws_instance.web.*.private_ip)}"
}
EOF
```
When you run apply, Terraform loads all files in the directory ending with .tf, so both input and output variable files are loaded.

6. View the execution plan by issuing the apply command:
```
terraform apply
```
7. Enter yes at the prompt to apply the execution plan to create the resources.

8. Use the output command to retrieve the ips output value:
```
terraform output ips
```
Creating outputs is more convenient than sifting through all the state attributes, and can make integration with automation scripts easy.

## Summary
In this Lab Step, you used input variables and built-in interpolation functions to create a pair of subnets in different availability zones, and a pair of instances in different subnets. You also used an output to make retrieving the IP addresses of the instances easy. You separated the input and output variables into different files to organize the configuration.












