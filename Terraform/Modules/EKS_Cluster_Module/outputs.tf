# This file defines the outputs for the EKS Cluster module.
# These outputs are necessary for configuring the Kubernetes and Helm providers.

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
  # The endpoint URL for the EKS cluster.
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  # The certificate authority data for the EKS cluster.
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
  # The name of the EKS cluster.
}