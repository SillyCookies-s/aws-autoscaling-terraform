terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_security_group" "app_server_sg" {
  name_prefix = "tt-as2-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "app_server" {
  name_prefix            = "terra-as1"
  image_id               = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx curl

    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)
    PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

    cat <<HTML > /var/www/html/index.html
    <!DOCTYPE html>
    <html>
      <head><title>EC2 Instance Info</title></head>
      <body>
        <h1>Deployed via Terraform & Auto Scaling</h1>
        <p><strong>Public IP:</strong> $PUBLIC_IP</p>
        <p><strong>Private IP:</strong> $PRIVATE_IP</p>
      </body>
    </html>
    HTML

    systemctl enable nginx
    systemctl restart nginx
  EOF
  )
}

resource "aws_lb" "app_server_alb" {
  name_prefix        = "tt-as4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app_server_sg.id]
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "app_server_tg" {
  name_prefix = "tt-as3"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    port                = "traffic-port"
    protocol            = "HTTP"
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "app_server_alb_l" {
  load_balancer_arn = aws_lb.app_server_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_server_tg.arn
  }
}

resource "aws_autoscaling_group" "app_server_aasg" {
  name_prefix               = "tt-as5"
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 3
  vpc_zone_identifier       = var.subnet_ids
  target_group_arns         = [aws_lb_target_group.app_server_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_server.id
    version = "$Latest"
  }
}