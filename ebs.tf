resource "aws_ebs_volume" "ai" {
  availability_zone = "us-east-1a"
  size              = 40

  tags = {
    Name = "ai"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.ai.id
  instance_id = module.ec2_ai.id
}