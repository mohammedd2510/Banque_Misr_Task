resource "aws_iam_role" "workernodes" {
  name = "eks-node-group-role"
 
  assume_role_policy = jsonencode({
   Statement = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
     Service = "ec2.amazonaws.com"
    }
   }]
   Version = "2012-10-17"
  })
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "EC2InstanceProfileForImageBuilderECRContainerBuilds" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role    = aws_iam_role.workernodes.name
 }
 
 resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role    = aws_iam_role.workernodes.name
 }




# Attach AmazonEBSCSIDriverPolicy to IAM Role
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.workernodes.name
}



# Read the policy from the JSON file
resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"
  policy      = file("./Modules/EKS_Cluster_Module/aws-alb-iam-policy.json") # Read the JSON file directly
}


# Attach the policy to the IAM role
resource "aws_iam_policy_attachment" "aws_load_balancer_controller_policy_attachment" {
  name       = "AWSLoadBalancerControllerIAMPolicyAttachment"
  roles      = [aws_iam_role.workernodes.name]
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
}

# Read the policy from the JSON file
resource "aws_iam_policy" "external_dns_policy" {
  name        = "ExternalDNS_IAM_Policy"
  description = "IAM policy for External DNS"
  policy      = file("./Modules/EKS_Cluster_Module/external-dns-iam-policy.json") # Read the JSON file directly
}


# Attach the policy to the IAM role
resource "aws_iam_policy_attachment" "external_dns_policy_attachment" {
  name       = "ExternalDNSIAMPolicyAttachment"
  roles      = [aws_iam_role.workernodes.name]
  policy_arn = aws_iam_policy.external_dns_policy.arn
}