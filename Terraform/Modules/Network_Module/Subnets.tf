# This Terraform configuration file defines two public subnets within a specified VPC.
# Each subnet is created in a different availability zone and is configured to assign public IP addresses to instances on launch.
# Additionally, the subnets are tagged for use with Kubernetes load balancers.

resource "aws_subnet" "Public_Subnet1" {
  vpc_id     = var.vpc_id  # The ID of the VPC where the subnet will be created
  cidr_block = var.Public_Subnet1_cidr  # The CIDR block for the subnet
  availability_zone = var.Availabillity_Zone1  # The availability zone for the subnet
  map_public_ip_on_launch = true  # Automatically assign a public IP address to instances launched in this subnet
  tags = {
    Name = "Public Subnet"  # Name tag for the subnet
    "kubernetes.io/role/elb" = "1"  # Tag indicating this subnet is for Kubernetes ELB
  }
}

output "Public_Subnet1_id" {
  value = aws_subnet.Public_Subnet1.id  # Output the ID of the first public subnet
}

resource "aws_subnet" "Public_Subnet2" {
  vpc_id     = var.vpc_id  # The ID of the VPC where the subnet will be created
  cidr_block = var.Public_Subnet2_cidr  # The CIDR block for the subnet
  availability_zone = var.Availabillity_Zone2  # The availability zone for the subnet
  map_public_ip_on_launch = true  # Automatically assign a public IP address to instances launched in this subnet
  tags = {
    Name = "Public Subnet2"  # Name tag for the subnet
    "kubernetes.io/role/elb" = "1"  # Tag indicating this subnet is for Kubernetes ELB
  }
}

output "Public_Subnet2_id" {
  value = aws_subnet.Public_Subnet2.id  # Output the ID of the second public subnet
}