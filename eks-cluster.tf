module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.10.0"
  cluster_name    = local.cluster_name
  cluster_version = "1.24"
  subnet_ids         = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  self_managed_node_group_defaults = {
    vpc_security_group_ids = ["gp2"]
  }

  self_managed_node_groups = {
    wrkrg1 = {
      name                          = "worker-group-1"
      instance_type                 = "t3.large"
      post_bootstrap_user_data           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      desired_size          = 2
      launch_template_name = "wrkrg1"
    }
    wrkrg2 = {
      name                          = "worker-group-2"
      instance_type                 = "t2.large"
      post_bootstrap_user_data           = "echo foo bar"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      desired_size          = 1
      launch_template_name = "wrkrg2"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_iam_role" "workers" {
  name = module.eks.cluster_iam_role_name
}
