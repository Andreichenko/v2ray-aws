#update ssm parameter for amazon image
data "aws_ssm_parameter" "linuxAMI-eu-central-1" {
  provider = aws.region-common
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# update key-pair for logging into EC2 in eu-central-1 region
resource "aws_key_pair" "common-key" {
  provider   = aws.region-common
  public_key = file("~/.ssh/id_rsa.pub")
  key_name   = "v2ray"
}

#create and bootstrap ec2 in eu-central-1 region
resource "aws_instance" "v2ray-server" {
  provider                    = aws.region-common
  ami                         = data.aws_ssm_parameter.linuxAMI-eu-central-1.value
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.common-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.v2ray-sg.id]
  subnet_id                   = aws_subnet.subnet-1a.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    encrypted             = false
    delete_on_termination = false
  }

  tags = {
    Name        = "v2ray-server"
    Owner       = "Aleksandr Andreichenko"
    Environment = "Production VPN"
    Type        = "t2-micro"
    Region      = "eu-central-1"
    Zone        = "zone-1a"
  }
}
