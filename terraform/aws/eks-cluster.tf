module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "17.1.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.small"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 1
      asg_min_size                  = 1
      asg_max_size                  = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "worker-group-2"
      instance_type                 = "t3.medium"
      additional_userdata           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      asg_desired_capacity          = 1
    },
  ]

  map_users = [
    {
      "groups" = [
        "system:masters"
      ]
      "userarn" = "arn:aws:iam::615740825886:user/avalette"
      "username" = "avalette"
    },
    {
      "groups" = [
        "system:masters"
      ]
      "userarn" = "arn:aws:iam::615740825886:user/asoni"
      "username" = "asoni"
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "flux2-bootstrap" {
  source  = "gohypergiant/flux2-bootstrap/kubernetes"
  version = "= 0.2.0"

  // Pass providers in explicitly to allow for multiple clusters
  providers = {
    kubernetes = kubernetes.flux2-kubernetes
    kubectl    = kubectl.flux2-kubectl
    flux       = flux.flux2-flux
    tls        = tls.flux2-tls
  }

  // Required inputs
  cluster_name = "lynceus-cluster"
  flux_git_url = "ssh://git@github.com/ValetteValette/gitops-istio"

  // Optional Inputs
  flux_git_path        = "clusters/my-cluster"
  flux_git_email       = "antoine.valette5@gmail.com"
  flux_git_branch      = "main"
  // flux_ssh_known_hosts = "your.private.git.server.io ssh-rsa AAAAB...."
  flux_sync_interval   = "1m"
  flux_deploy_image_automation = true

}

resource "github_repository_deploy_key" "flux_deploy_key" {
  title      = "flux_deploy_key_eks"
  repository = "gitops-istio"
  key        = module.flux2-bootstrap.github_deploy_key
  read_only  = "false"
}
