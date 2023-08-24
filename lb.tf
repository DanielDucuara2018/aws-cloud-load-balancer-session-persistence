resource "aws_security_group" "security_group_lb" {
  name         = "terraform-security-group-for-load-balancer"
  description  = "Terraform security group for load balancer"
  vpc_id       = aws_vpc.vpc01.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
      Name = "terraform-security-group-for-load-balancer"
  }
}

resource "aws_lb" "load_balancer01" {
  name                       = "terraform-balancer"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.security_group_lb.id]
  subnets                    = [aws_subnet.subnet_private02.id, aws_subnet.subnet_public.id]
  enable_deletion_protection = false
  depends_on                 = [aws_route.route01]

  tags = {
    Name = "terraform-balancer"
  }
}


resource "aws_lb_target_group" "load_balancer_target_group01" {
  name     = "terraform-balancer-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc01.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 10
    matcher             = 200
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 3
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener" "load_balancer_listener01" {
  load_balancer_arn = aws_lb.load_balancer01.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_target_group01.arn
  }
}

# TODO merge this two aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "load_balancer_target_group_attachment01" {
  target_group_arn = aws_lb_target_group.load_balancer_target_group01.arn
  target_id        = aws_instance.vm02_private.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "load_balancer_target_group_attachment02" {
  target_group_arn = aws_lb_target_group.load_balancer_target_group01.arn
  target_id        = aws_instance.vm03_private.id
  port             = 80
}