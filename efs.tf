module "efs" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-efs.git"


  name = "ai-efs"
  # Mount targets / security group
  mount_targets = {
    "us-east-1a" = {
      subnet_id = "subnet-094213aa4b11d5331"
    }
    "us-east-1b" = {
      subnet_id = "subnet-02d71c63bc9077979"
    }
    "us-east-1c" = {
      subnet_id = "subnet-00ee818914c56c301"
    }
  }
  security_group_description = "Example EFS security group"
  security_group_vpc_id      = module.vpc_ai.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


}