resource "aws_iam_role" "instance_role" {
  name = "instance_profile_role_ai"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "instance_ssm_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_role_policy_attachment" "instance_dynamodb_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
resource "aws_iam_role_policy_attachment" "instance_ecr_policy" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}
resource "aws_iam_instance_profile" "instance_profile" {
  name = "instance_profile_ai"
  role = aws_iam_role.instance_role.name

}


module "iam_group_with_policies" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-iam.git//modules/iam-group-with-policies"

  # git::https://github.com/
  name = "aigroup"

  group_users = [
    # "sachin.asokan",
    "sachin"
    # ,
    # "sakshi.chaudhary"
  ]

  attach_iam_self_management_policy = false

  custom_group_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]

  custom_group_policies = [
    {
      name   = "AllowS3Listing"
      policy = data.aws_iam_policy_document.bucket.json
    },
    {
      name   = "SagemakerRPermission"
      policy = data.aws_iam_policy_document.sagemaker.json
    }
  ]
}