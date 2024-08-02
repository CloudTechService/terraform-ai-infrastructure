terraform {
  backend "s3" {
    bucket         = "terraform-tfstate-ai-cloud"
    key            = "state/terraform-state.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ai-terraform-backend"
  }
}