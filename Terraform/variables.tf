variable "cidr_blocks" {
    type = map(string)
  
}
variable "Availabillity_Zones"{
    type = list(string)
}

variable "my_domain_hostedzone_id" {
    type = string
}
variable "vpc_id" {
    type = string
}
variable "igw_id" {
    type = string
}

variable "TXT_OWNER_ID" {
  type = string
}
variable "GITHUB_TOKEN" {
  type = string
}