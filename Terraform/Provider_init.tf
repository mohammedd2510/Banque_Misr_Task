# This Terraform configuration file initializes the required providers and configures the backend for storing the state file in an S3 bucket.
# It also sets up the AWS, Kubernetes, and Helm providers with the necessary configurations.

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"  # Specifies the AWS provider source and version
      version = "~> 5.0"  # Uses version 5.x of the AWS provider
    }
    tls = {
      source = "hashicorp/tls"  # Specifies the TLS provider source and version
      version = "~> 3.0"  # Uses version 3.x of the TLS provider
    }
    kubernetes = {
      source = "hashicorp/kubernetes"  # Specifies the Kubernetes provider source and version
      version = "~> 2.0"  # Uses version 2.x of the Kubernetes provider
    }
    helm = {
      source = "hashicorp/helm"  # Specifies the Helm provider source and version
      version = "~> 2.0"  # Uses version 2.x of the Helm provider
    }
    external = {
      source = "hashicorp/external"  # Specifies the External provider source and version
      version = "~> 2.0"  # Uses version 2.x of the External provider
    }
  }
  backend "s3" {
    encrypt = true  # Enables encryption for the state file
    bucket = "terraformm-state-s3"  # Specifies the S3 bucket name for storing the state file
    dynamodb_table = "terraform-lock-dynamodb"  # Specifies the DynamoDB table for state locking
    region = "us-east-1"  # Specifies the AWS region for the S3 bucket and DynamoDB table
    key = "statefile"  # Specifies the key for the state file in the S3 bucket
  }
}

provider "aws" {
  region = "us-east-1"  # Specifies the AWS region for the AWS provider
}

provider "kubernetes" {
  host                   = module.Eks_Cluster_Module.eks_cluster_endpoint  # Specifies the Kubernetes cluster endpoint
  cluster_ca_certificate = base64decode(module.Eks_Cluster_Module.eks_cluster_certificate_authority)  # Decodes and sets the cluster CA certificate

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"  # Specifies the API version for the exec plugin
    command     = "aws"  # Specifies the command to execute for authentication
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.Eks_Cluster_Module.eks_cluster_name]  # Specifies the arguments for the command
  }
}

provider "helm" {
  kubernetes {
    host                   = module.Eks_Cluster_Module.eks_cluster_endpoint  # Specifies the Kubernetes cluster endpoint for Helm
    cluster_ca_certificate = base64decode(module.Eks_Cluster_Module.eks_cluster_certificate_authority)  # Decodes and sets the cluster CA certificate for Helm

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"  # Specifies the API version for the exec plugin
      command     = "aws"  # Specifies the command to execute for authentication
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.Eks_Cluster_Module.eks_cluster_name]  # Specifies the arguments for the command
    }
  }
}