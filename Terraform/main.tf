module "Network_Module" {
    source = "./Modules/Network_Module"
    Public_Subnet1_cidr= var.cidr_blocks["public_subnet1_cidr"]
    Public_Subnet2_cidr= var.cidr_blocks["public_subnet2_cidr"]
    Availabillity_Zone1 = var.Availabillity_Zones[0]
    Availabillity_Zone2 = var.Availabillity_Zones[1]
    vpc_id = var.vpc_id
    igw_id = var.igw_id
}

module "Eks_Cluster_Module" {
    source = "./Modules/EKS_Cluster_Module"
    Public_Subnet1_id = module.Network_Module.Public_Subnet1_id 
    Public_Subnet2_id = module.Network_Module.Public_Subnet2_id
    security_group_id = module.Network_Module.Public_Security_Group_id
}

module "ACM_Module" {
  source = "./Modules/ACM_Module"
  my_domain_hostedzone_id = var.my_domain_hostedzone_id
  
}