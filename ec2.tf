# update ssm parameter for amazon image
data "aws_ssm_parameter" "linuxAMI-eu-central-1" {
  provider = aws.region-common
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# update key-pair for logging into EC2 in eu-central-1 region
resource "aws_key_pair" "common-key" {
  provider   = aws.region-common
  public_key = file("~/.ssh/id_rsa.pub")
  key_name   = "xray-server-proxy"
}

# Network Load Balancer (NLB) for high-performance TCP proxy traffic
resource "aws_lb" "xray-nlb" {
  provider           = aws.region-common
  name               = "xray-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.subnet-1a.id, aws_subnet.subnet-1b.id, aws_subnet.subnet-1c.id]

  tags = {
    Name        = "xray-nlb"
    Owner       = "Aleksandr Andreichenko"
    Environment = "Production"
  }
}

# Target Group for NLB
resource "aws_lb_target_group" "xray-tg" {
  provider    = aws.region-common
  name        = "xray-target-group"
  port        = var.xray_port
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc-central-1.id
  target_type = "instance"

  health_check {
    port     = var.xray_port
    protocol = "TCP"
    interval = 30
  }
}

# Listener for NLB routing traffic to the Target Group
resource "aws_lb_listener" "xray-listener" {
  provider          = aws.region-common
  load_balancer_arn = aws_lb.xray-nlb.arn
  port              = var.xray_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.xray-tg.arn
  }
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "xray-template" {
  provider      = aws.region-common
  name_prefix   = "xray-template-"
  image_id      = data.aws_ssm_parameter.linuxAMI-eu-central-1.value
  instance_type = var.instance_type
  key_name      = aws_key_pair.common-key.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.xray-sg.id]
  }

  # 20 GB gp3 storage is optimized for size and cost, auto-deletes on termination
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  # Automated bootstrapping of xray service
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y curl
              # Install Xray via official release script
              bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)
              systemctl enable xray
              systemctl start xray
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "xray-asg-node"
      Owner       = "Aleksandr Andreichenko"
      Environment = "Production VPN"
    }
  }
}

# Auto Scaling Group spanning 3 Availability Zones
resource "aws_autoscaling_group" "xray-asg" {
  provider            = aws.region-common
  name_prefix         = "xray-asg-"
  vpc_zone_identifier = [aws_subnet.subnet-1a.id, aws_subnet.subnet-1b.id, aws_subnet.subnet-1c.id]
  target_group_arns   = [aws_lb_target_group.xray-tg.arn]

  min_size         = var.asg_min_size
  max_size         = var.asg_max_size
  desired_capacity = var.asg_desired_capacity

  launch_template {
    id      = aws_launch_template.xray-template.id
    version = "$Latest"
  }

  # Health check settings
  health_check_type         = "ELB"
  health_check_grace_period = 300

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy based on average CPU utilization
resource "aws_autoscaling_policy" "xray-cpu-policy" {
  provider               = aws.region-common
  name                   = "xray-cpu-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.xray-asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
