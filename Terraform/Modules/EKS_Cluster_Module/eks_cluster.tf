# This Terraform configuration file defines an AWS EKS (Elastic Kubernetes Service) cluster.
# It specifies the cluster name, IAM role, VPC configuration, and dependencies on IAM role policy attachments.

resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-cluster"  # Name of the EKS cluster
  role_arn = aws_iam_role.eks-iam-role.arn  # ARN of the IAM role for the EKS cluster

  vpc_config {
    subnet_ids = [var.Public_Subnet1_id, var.Public_Subnet2_id]  # List of subnet IDs for the EKS cluster
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,  # Dependency on AmazonEKSClusterPolicy attachment
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-EKS,  # Dependency on AmazonEC2ContainerRegistryReadOnly-EKS attachment
  ]
}
