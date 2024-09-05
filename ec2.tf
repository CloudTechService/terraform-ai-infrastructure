module "ec2_ai" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ec2-instance.git?ref=4f8387d"

  name = "${var.env}-chromadb-ai"

  instance_type = "t2.medium"
  ami           = local.ec2.ami

  key_name                    = "health_approval"
  monitoring                  = false
  vpc_security_group_ids      = [module.web_server_sg.security_group_id]
  subnet_id                   = module.vpc_ai.public_subnets[0]
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  root_block_device = [{
    volume_size           = 90    # Size of the root volume in GB
    volume_type           = "gp3" # Type of the root volume (e.g., gp2, io1)
    delete_on_termination = true  # Whether the volume should be deleted when the instance is terminated
  }]


  user_data = <<-EOF
                #!/bin/bash
                # Update the package list
                apt-get update

                # Install SSM Agent
                snap install amazon-ssm-agent --classic

                # Start SSM Agent
                systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
                systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service

                sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
                libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                libncurses5-dev libncursesw5-dev xz-utils tk-dev \
                libffi-dev liblzma-dev python3-openssl git


                EOF
  tags = {
    Terraform   = "true"
    Environment = "qa"
    Project     = "ai"
  }
}


resource "aws_eip" "ai" {
  instance = module.ec2_ai.id
  tags = {
    Name = "${var.env}-ai"
  }
}






