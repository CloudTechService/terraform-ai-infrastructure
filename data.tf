
data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}


#Define the IAM policy document
data "aws_iam_policy_document" "bucket" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::neura-rag-bot-data"]
  }

  statement {
    # Allow reading and uploading files in the bucket
    actions = [
      "s3:GetObject", # Read files
      "s3:PutObject"  # Upload files
    ]
    resources = ["arn:aws:s3:::neura-rag-bot-data/*"]
  }
}



data "aws_iam_policy_document" "sagemaker" {
  statement {
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:AttachRolePolicy",
      "iam:PassRole"
    ]
    resources = ["arn:aws:iam::093254158936:role/service-role/AmazonSageMaker-ExecutionRole-*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["sagemaker:*"]
    resources = ["*"]
  }
}