
module "vpc_ai" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=f8cd168"
  name   = local.vpc.name_vpc
  cidr   = local.vpc.vpc_cidr

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets  = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.vpc_cidr, 8, k)]
  public_subnets   = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.vpc_cidr, 8, k + 4)]
  database_subnets = [for k, v in local.vpc.azs : cidrsubnet(local.vpc.vpc_cidr, 8, k + 8)]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  private_subnet_names  = ["Private Subnet One", "Private Subnet Two"]
  database_subnet_names = ["DB Subnet One"]

  create_database_subnet_group = false

  tags = {
    Terraform   = "true"
    Environment = "qa"
    Project     = "ai"
  }

}