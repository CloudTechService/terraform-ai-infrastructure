
locals {

  name         = "ai"
  service_name = "llm"
  vpc_cidr     = "10.0.0.0/16"
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)

  container_name = "ecsdemo-frontend"
  container_port = 8888
}
resource "aws_service_discovery_private_dns_namespace" "example" {
  name = "example"
  vpc  = module.vpc_ai.vpc_id
}

################################################################################
# Cluster
################################################################################

module "ecs_ai" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "ecs-integrated"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }

  }

  services = {
    ecsdemo-frontend = {
      cpu    = 16384
      memory = 32768

      # Container definition(s)
      container_definitions = {
        ecs-app = {
          cpu       = 8192
          memory    = 16384
          essential = true
          image     = "093254158936.dkr.ecr.us-east-1.amazonaws.com/ai:latest"
          port_mappings = [
            {
              name          = "ecs-sample"
              containerPort = 80
              hostPort      = 80
              protocol      = "tcp"
            }

          ]
          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false


          enable_cloudwatch_logging = true

          memory_reservation = 100
        }
      }



      # service_connect_configuration = {
      #   namespace = "example"
      #   # aws_service_discovery_private_dns_namespace.example.id
      #   services = [
      #     {
      #       port_name      = "ecs-sample"
      #       discovery_name = "ecs-sample"
      #       client_aliases = [
      #         {
      #           port     = 80
      #           dns_name = "ecs-sample"
      #         }
      #       ]
      #     }
      #   ]
      # }

      # load_balancer = {
      #   service = {
      #     target_group_arn = "arn:aws:elasticloadbalancing:eu-west-1:1234567890:targetgroup/bluegreentarget1/209a844cd01825a4"
      #     container_name   = "ecs-sample"
      #     container_port   = 80
      #   }
      # }


      subnet_ids       = module.vpc_ai.public_subnets
      assign_public_ip = true

      security_group_rules = {

        https_ingress = {
          type        = "ingress"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
        }

        http_ingress = {
          type        = "ingress"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
        }

        eight_thousand_ingress = {
          type        = "ingress"
          from_port   = 8000
          to_port     = 8000
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
        }

        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }

    ecs-data = {
      cpu    = 16384
      memory = 32768

      # Container definition(s)
      container_definitions = {

        ecs-chroma = {
          cpu                       = 512
          memory                    = 1024
          essential                 = true
          image                     = "093254158936.dkr.ecr.us-east-1.amazonaws.com/ai:chromadblatest"
          readonly_root_filesystem  = false
          readonly_root_filesystem  = false
          enable_cloudwatch_logging = true
          port_mappings = [
            {
              name          = "ecs-8000-port"
              containerPort = 8000
              hostPort      = 8000
              protocol      = "tcp"
            },
          ]
          memory_reservation = 50
        }
      }
      subnet_ids       = module.vpc_ai.public_subnets
      assign_public_ip = true
      security_group_rules = {
        https_ingress = {
          type        = "ingress"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
        }

        http_ingress = {
          type        = "ingress"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
        }

        eight_thousand_ingress = {
          type        = "ingress"
          from_port   = 8000
          to_port     = 8000
          protocol    = "tcp"
          description = "Service port"
          cidr_blocks = ["0.0.0.0/0"]
        }

        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}














# module "ecs_cluster" {
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/cluster"

#   cluster_name = local.name

#   # Capacity provider
#   fargate_capacity_providers = {
#     FARGATE = {
#       default_capacity_provider_strategy = {
#         weight = 50
#         base   = 20
#       }
#     }

#   }



#   tags = local.tags
# }


# ################################################################################
# # Standalone Task Definition (w/o Service)
# ################################################################################

# module "ecs_task_definition" {
#   source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git//modules/service"

#   # # Service
#   name        = "${local.name}-alone"
#   cluster_arn = module.ecs_cluster.arn
#   cpu         = 16384
#   memory      = 32768


#   ephemeral_storage = {
#     size_in_gib = "120"
#   }


#   runtime_platform = {
#     cpu_architecture        = "X86_64"
#     operating_system_family = "LINUX"
#   }

#   enable_execute_command = true

#   # Container definition(s)
#   container_definitions = {


#     al2023 = {
#       image                    = "093254158936.dkr.ecr.us-east-1.amazonaws.com/ai:latest"
#       readonly_root_filesystem = false
#       cpu                      = 8192
#       memory                   = 16384
#       interactive              = true

#       port_mappings = [
#         {
#           name          = "ecs-sample"
#           containerPort = 80
#           hostPort      = 80
#           protocol      = "tcp"
#         },
#         {
#           name          = "ecs-8000-port"
#           containerPort = 8000
#           hostPort      = 8000
#           protocol      = "tcp"
#         },

#       ]
#       linuxParameters = [{
#         enable_execute_command = true
#         initProcessEnabled     = true

#         }
#       ]
#       #


#     },
#     chroma = {
#       image                    = "093254158936.dkr.ecr.us-east-1.amazonaws.com/ai:chromadblatest"
#       readonly_root_filesystem = false
#       cpu                      = 8192
#       memory                   = 16384
#       interactive              = true

#       # port_mappings = [
#       #   {
#       #     name          = "ecs-sample"
#       #     containerPort = 80
#       #     hostPort      = 80
#       #     protocol      = "tcp"
#       #   },
#       #   {
#       #     name          = "ecs-8000-port"
#       #     containerPort = 8000
#       #     hostPort      = 8000
#       #     protocol      = "tcp"
#       #   },

#       # ]
#       linuxParameters = [{
#         enable_execute_command = true
#         initProcessEnabled     = true

#         }
#       ]
#       #


#     }
#   }

#   subnet_ids = module.vpc_ai.public_subnets

#   security_group_rules = {

#     https_ingress = {
#       type        = "ingress"
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       description = "Service port"
#       cidr_blocks = ["0.0.0.0/0"]
#     }

#     http_ingress = {
#       type        = "ingress"
#       from_port   = 80
#       to_port     = 80
#       protocol    = "tcp"
#       description = "Service port"
#       cidr_blocks = ["0.0.0.0/0"]
#     }

#     eight_thousand_ingress = {
#       type        = "ingress"
#       from_port   = 8000
#       to_port     = 8000
#       protocol    = "tcp"
#       description = "Service port"
#       cidr_blocks = ["0.0.0.0/0"]
#     }

#     egress_all = {
#       type        = "egress"
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }
#   assign_public_ip = true

#   tags = local.tags
# }

