data "aws_ssm_parameter" "amazon_eks_ami" {
name = "/aws/service/eks/optimized-ami/1.29/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "eks_node_lt" {
  name_prefix   = "eks-node-lt"
  image_id = data.aws_ssm_parameter.amazon_eks_ami.insecure_value
  instance_type = "t2.medium"

  metadata_options {
    http_tokens                 = "required"  # Optional, but recommended for security
    http_put_response_hop_limit = 3
    http_endpoint               = "enabled"
  }
 vpc_security_group_ids = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]  # Attach security group
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-node"
    }
  }
   block_device_mappings {
    device_name = "/dev/xvda"  # Default root volume for Amazon Linux 2
    ebs {
      volume_size = 40  # Set disk size to 40GB here
      volume_type = "gp3"
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
  )
}


resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  node_group_name = "eks-workernodes"
  node_role_arn  = aws_iam_role.workernodes.arn
  launch_template {
    id      = aws_launch_template.eks_node_lt.id
    version = "$Latest"
  }
  subnet_ids   = [var.Public_Subnet1_id,var.Public_Subnet2_id]

 
  scaling_config {
   desired_size = 2
   max_size   = 3
   min_size   = 2
  }
   tags = {
    Name = "eks-node-group"
  }
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
 }
 resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_node_group" {
  security_group_id =  aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
