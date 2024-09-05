locals {
  vpc = {
    name_vpc = "vpc-ai"
    vpc_cidr = "10.0.0.0/16"
    azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  }
  ec2 = {

    ami = "ami-04a81a99f5ec58529"
  }

  #   dynamodb = {
  #     name = "health_approval"
  #   }

  ecs = {
    cluster_name        = "ai"
    ecs_service_name    = "ai_service"
    container1_name     = "ai_container"
    container1_port     = "3000"
    container1_hostport = "3000"
    region              = "us-east-1"
    fargate_name        = "ai_fargate"
  }

  tags = {
    Name  = "dev"
    Owner = "DevOps"
  }
}

