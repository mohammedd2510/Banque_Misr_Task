terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
        tls = {
            source = "hashicorp/tls"
            version = "~> 3.0"
        }
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.0"
        }
        helm = {
            source = "hashicorp/helm"
            version = "~> 2.0"
        }
        external = {
            source = "hashicorp/external"
            version = "~> 2.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.Eks_Cluster_Module.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.Eks_Cluster_Module.eks_cluster_certificate_authority)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.Eks_Cluster_Module.eks_cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.Eks_Cluster_Module.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.Eks_Cluster_Module.eks_cluster_certificate_authority)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.Eks_Cluster_Module.eks_cluster_name]
    }
  }
}