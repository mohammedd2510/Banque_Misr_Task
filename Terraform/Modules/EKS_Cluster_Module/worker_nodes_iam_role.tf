# This Terraform configuration file defines the IAM role and policy attachments for EKS worker nodes.
# It includes the creation of an IAM role for the worker nodes, attaching necessary AWS managed policies,
# and custom policies for AWS Load Balancer Controller and External DNS.

resource "aws_iam_role" "workernodes" {
  name = "eks-node-group-role"  # Name of the IAM role

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"  # Action to allow assuming the role
      Effect = "Allow"  # Allow the action
      Principal = {
        Service = "ec2.amazonaws.com"  # EC2 service is allowed to assume this role
      }
    }]
    Version = "2012-10-17"  # Policy version
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"  # ARN of the AmazonEKSWorkerNodePolicy
  role       = aws_iam_role.workernodes.name  # Attach to the worker nodes role
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"  # ARN of the AmazonEKS_CNI_Policy
  role       = aws_iam_role.workernodes.name  # Attach to the worker nodes role
}

resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"  # ARN of the EC2InstanceProfileForImageBuilderECRContainerBuilds policy
  role       = aws_iam_role.workernodes.name  # Attach to the worker nodes role
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"  # ARN of the AmazonEC2ContainerRegistryReadOnly policy
  role       = aws_iam_role.workernodes.name  # Attach to the worker nodes role
}

# Attach AmazonEBSCSIDriverPolicy to IAM Role
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"  # ARN of the AmazonEBSCSIDriverPolicy
  role       = aws_iam_role.workernodes.name  # Attach to the worker nodes role
}

# Read the policy from the JSON file
resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"  # Name of the custom policy
  description = "IAM policy for AWS Load Balancer Controller"  # Description of the policy
  policy      = file("./Modules/EKS_Cluster_Module/aws-alb-iam-policy.json")  # Read the JSON file directly
}

# Attach the policy to the IAM role
resource "aws_iam_policy_attachment" "aws_load_balancer_controller_policy_attachment" {
  name       = "AWSLoadBalancerControllerIAMPolicyAttachment"  # Name of the policy attachment
  roles      = [aws_iam_role.workernodes.name]  # Attach to the worker nodes role
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn  # ARN of the custom policy
}

# Read the policy from the JSON file
resource "aws_iam_policy" "external_dns_policy" {
  name        = "ExternalDNS_IAM_Policy"  # Name of the custom policy
  description = "IAM policy for External DNS"  # Description of the policy
  policy      = file("./Modules/EKS_Cluster_Module/external-dns-iam-policy.json")  # Read the JSON file directly
}

# Attach the policy to the IAM role
resource "aws_iam_policy_attachment" "external_dns_policy_attachment" {
  name       = "ExternalDNSIAMPolicyAttachment"  # Name of the policy attachment
  roles      = [aws_iam_role.workernodes.name]  # Attach to the worker nodes role
  policy_arn = aws_iam_policy.external_dns_policy.arn  # ARN of the custom policy
}
