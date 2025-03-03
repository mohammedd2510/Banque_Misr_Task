# This Terraform configuration file defines three modules: Network_Module, Eks_Cluster_Module, and ACM_Module.
# Each module is sourced from a local path and is configured with various input variables.
# The Network_Module sets up the network infrastructure, the Eks_Cluster_Module sets up the EKS cluster,
# and the ACM_Module sets up the ACM (AWS Certificate Manager) resources.

module "Network_Module" {
  source = "./Modules/Network_Module"  # Source path for the Network_Module
  Public_Subnet1_cidr = var.cidr_blocks["public_subnet1_cidr"]  # CIDR block for the first public subnet
  Public_Subnet2_cidr = var.cidr_blocks["public_subnet2_cidr"]  # CIDR block for the second public subnet
  Availabillity_Zone1 = var.Availabillity_Zones[0]  # First availability zone
  Availabillity_Zone2 = var.Availabillity_Zones[1]  # Second availability zone
  vpc_id = var.vpc_id  # VPC ID
  igw_id = var.igw_id  # Internet Gateway ID
}

module "Eks_Cluster_Module" {
  source = "./Modules/EKS_Cluster_Module"  # Source path for the EKS_Cluster_Module
  Public_Subnet1_id = module.Network_Module.Public_Subnet1_id  # ID of the first public subnet from Network_Module
  Public_Subnet2_id = module.Network_Module.Public_Subnet2_id  # ID of the second public subnet from Network_Module
  security_group_id = module.Network_Module.Public_Security_Group_id  # Security group ID from Network_Module
}

module "ACM_Module" {
  source = "./Modules/ACM_Module"  # Source path for the ACM_Module
  my_domain_hostedzone_id = var.my_domain_hostedzone_id  # Hosted zone ID for the domain
}