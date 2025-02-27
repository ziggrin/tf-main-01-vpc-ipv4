locals {
  lb_tags = {
    Environment = "preprod"
    Project     = "omega"
    Component   = "load-balancer"
    IaaC        = "terraform"
  }
}

######
## Load balancer
######

## Preprod-omega
resource "aws_lb" "preprod-omega" {
  name               = "preprod-omega"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.load_balancer_allow_all_http_https.id ]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
#   # Might turn on access logs later
#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }
  tags = merge(local.lb_tags, {
    Name = "preprod-omega"
  })
}

## Preprod-omega - Listeners
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.preprod-omega.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type = "redirect"

    redirect {
      protocol = "HTTPS"
      port     = "443"
      host     = "#{host}"
      path     = "/#{path}"
      query    = "#{query}"
      status_code = "HTTP_301"
    }
  }

  tags = local.lb_tags
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.preprod-omega.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Service unavailable"
      status_code  = "503"
    }
  }

  tags = local.lb_tags
}
