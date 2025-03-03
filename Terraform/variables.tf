# This file defines the input variables for the Terraform configuration.
# These variables allow for customization and flexibility when deploying infrastructure.

variable "cidr_blocks" {
    type = map(string)
    # A map of CIDR blocks to be used for network configuration.
}

variable "Availabillity_Zones" {
    type = list(string)
    # A list of availability zones where resources will be deployed.
}

variable "my_domain_hostedzone_id" {
    type = string
    # The ID of the hosted zone for the domain.
}

variable "vpc_id" {
    type = string
    # The ID of the VPC where resources will be deployed.
}

variable "igw_id" {
    type = string
    # The ID of the Internet Gateway associated with the VPC.
}

variable "TXT_OWNER_ID" {
    type = string
    # The owner ID for TXT records (route53 hosted zone id).
}

variable "GITHUB_TOKEN" {
    type = string
    # The GitHub token for authentication.
}