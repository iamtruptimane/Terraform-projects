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
    "us-west-2" = "ami-093467ec28ae4fe03"

    "us-east-1" = "ami-0230bd60aa48260c6"

  }
}