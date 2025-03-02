resource "aws_subnet" "Public_Subnet1" {
  vpc_id     = var.vpc_id
  cidr_block = var.Public_Subnet1_cidr
  availability_zone = var.Availabillity_Zone1
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet"
    "kubernetes.io/role/elb" = "1"
  }
}
output "Public_Subnet1_id" {
  value = aws_subnet.Public_Subnet1.id
  
}
resource "aws_subnet" "Public_Subnet2" {
  vpc_id     = var.vpc_id
  cidr_block = var.Public_Subnet2_cidr
  availability_zone = var.Availabillity_Zone2
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet2"
   "kubernetes.io/role/elb" = "1"
  }
}

output "Public_Subnet2_id" {
  value = aws_subnet.Public_Subnet2.id
  
}