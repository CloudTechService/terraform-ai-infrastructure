module "iam_group_with_policies" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-group-with-policies"

  name = "aigroup"

  group_users = [
    "sachin.asokan",
    "sachin"
    # ,
    # "sakshi.chaudhary"
  ]

  attach_iam_self_management_policy = false

  #   custom_group_policy_arns = [
  #     "arn:aws:iam::aws:policy/AdministratorAccess",
  #   ]

  custom_group_policies = [
    {
      name   = "AllowS3Listing"
      policy = data.aws_iam_policy_document.bucket.json
    }
  ]
}


# module "iam_user" {
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-user"

#   name          = "sachin.asokan"
#   force_destroy = true

#   pgp_key = "keybase:test"

#   password_reset_required = true
# }