resource "helm_release" "aws_load_balancer_controller" {
  name            = "aws-load-balancer-controller"
  chart           = "../Helm_Charts/aws-load-balancer-controller-1.11.0/aws-load-balancer-controller/"  # Path to local Helm chart
  namespace       = "kube-system"  # Namespace to install the chart
  #create_namespace = true  # Equivalent to --create-namespace

  values = [file("../Helm_Charts/aws-load-balancer-controller-1.11.0/aws-load-balancer-controller/my_values.yaml")]  # Path to custom values file

}

resource "helm_release" "aws_ebs_csi_driver" {
  name            = "aws-ebs-csi-driver"
  chart           = "../Helm_Charts/aws-ebs-csi-driver-2.40.1/aws-ebs-csi-driver/"  # Path to local Helm chart
  namespace       = "kube-system"  # Namespace to install the chart
}

resource "helm_release" "sonar_qube" {
  name            = "sonarqube"
  chart           = "../Helm_Charts/sonarqube-2025.1.0/sonarqube/"  # Official Helm chart
  namespace       = "sonarqube"  # Namespace to install the chart
  create_namespace = true  # Equivalent to --create-namespace

  values = [file("../Helm_Charts/sonarqube-2025.1.0/sonarqube/my_values.yaml")]  # Path to custom values file
  depends_on = [ helm_release.aws_load_balancer_controller , helm_release.aws_ebs_csi_driver , helm_release.external_dns ]
}

resource "helm_release" "external_dns" {
  name            = "external-dns"
  chart           = "../Helm_Charts/external-dns-8.7.5/external-dns/"  # Official Helm chart
  namespace       = "kube-system"  # Namespace to install the chart
  create_namespace = true  # Equivalent to --create-namespace

  values = [file("../Helm_Charts/external-dns-8.7.5/external-dns/my_values.yaml")]  # Path to custom values file

  set {
    name  = "txtOwnerId"
    value = var.TXT_OWNER_ID 
  }
  set {
    name  = "aws.credentials.accessKey"
    value = data.external.aws_creds.result["aws_access_key_id"]

  }
  set {
    name  = "aws.credentials.secretKey"
    value = data.external.aws_creds.result["aws_secret_access_key"]
  }

}

resource "helm_release" "arc_runner_scale_set_controller" {
  name            = "arc-runner-scale-set-controller"
  chart           = "../Helm_Charts/gha-runner-scale-set-controller-0.10.1/gha-runner-scale-set-controller/"  # Official Helm chart
  namespace       = "arc-system"  # Namespace to install the chart
  create_namespace = true  # Equivalent to --create-namespace
}

resource "helm_release" "arc_runner_scale_set" {
  name            = "arc-runner-set"
  chart           = "../Helm_Charts/gha-runner-scale-set-0.10.1/gha-runner-scale-set/"  # Official Helm chart
  namespace       = "arc-runners"  # Namespace to install the chart
  create_namespace = true  # Equivalent to --create-namespace
  values = [file("../Helm_Charts/gha-runner-scale-set-0.10.1/gha-runner-scale-set/my_values.yaml")]  # Path to custom values file
    set {
        name  = "githubConfigSecret.github_token"
        value = var.GITHUB_TOKEN
    }
    depends_on = [ helm_release.arc_runner_scale_set_controller ]
}
 
