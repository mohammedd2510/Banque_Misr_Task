# This Terraform configuration file sets up an EKS node group with a launch template.
# It retrieves the latest Amazon EKS optimized AMI, creates a launch template for the EKS worker nodes,
# and configures an EKS node group to use this launch template. Additionally, it sets up a security group ingress rule.

data "aws_ssm_parameter" "amazon_eks_ami" {
  name = "/aws/service/eks/optimized-ami/1.29/amazon-linux-2/recommended/image_id"  # Retrieves the latest Amazon EKS optimized AMI ID from SSM Parameter Store
}

resource "aws_launch_template" "eks_node_lt" {
  name_prefix   = "eks-node-lt"  # Prefix for the launch template name
  image_id = data.aws_ssm_parameter.amazon_eks_ami.insecure_value  # Uses the AMI ID retrieved from SSM
  instance_type = "t2.medium"  # Specifies the instance type for the worker nodes

  metadata_options {
    http_tokens                 = "required"  # Optional, but recommended for security
    http_put_response_hop_limit = 3  # Limits the number of hops for instance metadata requests
    http_endpoint               = "enabled"  # Enables the instance metadata service
  }

  vpc_security_group_ids = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]  # Attach security group

  tag_specifications {
    resource_type = "instance"  # Specifies that the tags are for EC2 instances
    tags = {
      Name = "eks-node"  # Tag for the EC2 instances
    }
  }

  block_device_mappings {
    device_name = "/dev/xvda"  # Default root volume for Amazon Linux 2
    ebs {
      volume_size = 40  # Set disk size to 40GB
      volume_type = "gp3"  # Specifies the volume type
    }
  }

  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="
--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
/etc/eks/bootstrap.sh ${aws_eks_cluster.eks_cluster.name}
--==MYBOUNDARY==--\
  EOF
  )  # User data script to bootstrap the EKS worker nodes
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.eks_cluster.name  # Name of the EKS cluster
  node_group_name = "eks-workernodes"  # Name of the node group
  node_role_arn  = aws_iam_role.workernodes.arn  # ARN of the IAM role for the worker nodes

  launch_template {
    id      = aws_launch_template.eks_node_lt.id  # ID of the launch template
    version = "$Latest"  # Uses the latest version of the launch template
  }

  subnet_ids   = [var.Public_Subnet1_id, var.Public_Subnet2_id]  # Subnet IDs for the worker nodes

  scaling_config {
    desired_size = 2  # Desired number of worker nodes
    max_size   = 3  # Maximum number of worker nodes
    min_size   = 2  # Minimum number of worker nodes
  }

  tags = {
    Name = "eks-node-group"  # Tag for the node group
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]  # Ensures the IAM role policies are attached before creating the node group
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_node_group" {
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id  # Security group ID
  cidr_ipv4         = "0.0.0.0/0"  # Allows traffic from all IPv4 addresses
  ip_protocol       = "-1"  # Allows all protocols
}
