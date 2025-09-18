resource "aws_lb" "test_nlb" {
  name               = var.test_nlb_name
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.test_fluentd_nlb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags = {
    environment = var.environment
    Name        = "test-fluentd-nlb-${var.environment}"
  }
}

resource "aws_lb_target_group" "test_fluentd_nlb_tg" {
  deregistration_delay              = "300"
  ip_address_type                   = "ipv4"
  load_balancing_cross_zone_enabled = "use_load_balancer_configuration"
  name                              = "test-fluentd-nlb-tg-${var.environment}"
  port                              = 443
  preserve_client_ip                = "true"
  protocol                          = "TCP"
  proxy_protocol_v2                 = false
  tags                              = merge(local.tags, { Service = "NLB" })
  tags_all                          = {}
  target_type                       = "instance"
  vpc_id                            = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 10
    matcher             = "200"
    path                = "/health"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 5
  }

  stickiness {
    cookie_duration = 0
    enabled         = false
    type            = "source_ip"
  }
}

resource "aws_lb_listener" "test_fluentd_nlb_listener" {
  load_balancer_arn = aws_lb.test_nlb.arn
  port              = 443
  protocol          = "TCP"
  tags              = {}
  tags_all          = {}

  default_action {
    target_group_arn = aws_lb_target_group.test_fluentd_nlb_tg.arn
    type             = "forward"
  }
}
