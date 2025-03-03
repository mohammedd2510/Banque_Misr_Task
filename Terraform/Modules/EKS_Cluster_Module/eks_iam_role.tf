# This Terraform configuration file defines an IAM role and attaches policies to it for an EKS cluster.
# The IAM role allows the EKS service to assume the role and perform actions on behalf of the cluster.
# Two policies are attached to the role: AmazonEKSClusterPolicy and AmazonEC2ContainerRegistryReadOnly.

resource "aws_iam_role" "eks-iam-role" {
    name = "eks-iam-role"  # Name of the IAM role

    path = "/"  # Path for the IAM role

    # Assume role policy for the EKS service
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"  # ARN of the AmazonEKSClusterPolicy
    role       = aws_iam_role.eks-iam-role.name  # Attach the policy to the IAM role
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"  # ARN of the AmazonEC2ContainerRegistryReadOnly policy
    role       = aws_iam_role.eks-iam-role.name  # Attach the policy to the IAM role
}
