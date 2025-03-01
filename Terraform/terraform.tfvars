# terraform.tfvars

cidr_blocks = {
  public_subnet1_cidr   = "172.31.2.0/24"
  public_subnet2_cidr  = "172.31.1.0/24"

}
Availabillity_Zones = [ "us-east-1a","us-east-1b" ]

my_domain_hostedzone_id = "Z0893131158UAGU66I0XE"

vpc_id = "vpc-0f714e262f6d057e2"
igw_id = "igw-01bcb0bea124de276"