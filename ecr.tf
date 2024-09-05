
################################################################################
# ECR Repository
################################################################################

module "ecr_disabled" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git"

  create = false
}



module "ecr" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecr.git"

  repository_name                   = "ai"
  repository_type                   = "private"
  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  repository_force_delete           = true
  repository_image_tag_mutability   = "MUTABLE"


  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

}