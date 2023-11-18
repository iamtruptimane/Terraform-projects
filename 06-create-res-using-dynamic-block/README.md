# Simplifying Terraform Configurations Using Dynamic Blocks
Dynamic blocks allow you to create nested blocks within a resource by iterating over a map or list-type variable. When dynamic blocks are applied to a resource, Terraform generates a nested block for each element of the given list or map variable. This cuts down on the amount of code needed to define multiple resource attributes of the same type.

The 05-create-res-using-dynamic-block directory contains two subdirectories: original and refactor. Each folder contains a main.tf file.

You will refactor the original Terraform configuration defined in the original/main.tf file. The refactored template will use dynamic blocks to iterate over list and map variables.


## /original/main.tf

An aws_vpc resource is defined with a CIDR block of 10.0.0.0/16 and is configured with a Name tag.

The aws_security_group resource is configured within the aws_vpc. The purpose of this security group is to define ingress and egress rules to allow or deny traffic within the VPC.

Each security group can contain one or more ingress or egress rules. These rules begin to add up within the security group definition, and developers must locate and update the security group rules each time a change is requested. These nested rules are a perfect use case for Terraform dynamic blocks.

The security group is configured with four rules.

Allow inbound traffic on Port 80 (HTTP) and 443 (HTTPS) from the public internet.

Allow inbound traffic on Port 22 (SSH) that originates from within the Amazon VPC CIDR block. This will allow only resources within the VPC to SSH into any EC2 instances associated with this security group.

Finally, allow all outbound traffic to the public internet.

## /refactor/main.tf

Dynamic blocks are similar to the count and for_each meta-arguments in that they are designed to create multiple resources or attributes within a template.

A key difference is that dynamic blocks produce nested blocks instead of multiple instances of a resource or type value. Dynamic blocks are more suitable for configuring multiple attributes within a resource.

Dynamic blocks are configured in conjunction with the for_each meta-argument to produce these nested blocks.

## local variables
Local variables will simplify the template and allow these values to be referenced throughout the template. The string variables used within the VPC and security group resource blocks are defined first, followed by the tags map type variable.

## Ingress and egress security groups
The ingress and egress security group rules are stored as a list of map-type variables. Each map represents a rule and will be referenced as the dynamic block iterates over each list.

## vpc resource block
The VPC resource block now obtains the cidr_block and tags values from the local variables within the template.

## Dynamic block
A dynamic block contains the following elements:

* The dynamic keyword defines the block and is followed by a label (ingress and egress)
* The for_each meta-argument defines the map or list variable to iterate over
* An iterator argument (not used) specifies the name of the current element in the iteration. When this argument is omitted, the label is used as the iterator argument.
* The content block contains the nested block definition. The keys of this content block will vary based on the nested attributes being defined.

Security group rules require the following attributes:

* from_port
* to_port
* protocol
* cidr_block

To retrieve the values of each map object in the ingress_rules list, you use the value function. The ITERATOR.value.KEY_NAME pattern is used to retrieve the value of the specific key in the map object (e.g. ingress_rules.value.from_port).

The resources defined in the refactor/main.tf file are now configured by referencing variables and with the help of dynamic, nested blocks.

This refactored template contains more lines of code but changes to tags or security group rules can be applied by updating the tags, ingress_rules, or egress_rules variables.

## Apply terraform workflow in refactor directory
```
terraform init
terraform plan
terraform apply
```










