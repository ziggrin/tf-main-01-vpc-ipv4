locals {
  sg_tags = {
    Environment = "preprod"
    Project     = "omega"
    Component   = "security-group"
    IaaC        = "terraform"
  }
}

############
## Security groups
############

## ICMP - allow all ingress
resource "aws_security_group" "icmp_allow_all_ingress" {
  name        = "icmp-allow-all-ingress"
  description = "Allow all ICMP inbound traffic"
  vpc_id      = module.vpc.vpc_id
  
  tags = merge(local.sg_tags, {
    Name = "icmp-allow-all-ingress"
  })
}

resource "aws_vpc_security_group_ingress_rule" "icmp_allow_all_ingress_ipv4_first_half" {
  security_group_id = aws_security_group.icmp_allow_all_ingress.id
  cidr_ipv4         = "0.0.0.0/1"
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "icmp_allow_all_ingress_ipv4_second_half" {
  security_group_id = aws_security_group.icmp_allow_all_ingress.id
  cidr_ipv4         = "128.0.0.0/1"
  from_port         = -1
  ip_protocol       = "icmp"
  to_port           = -1
}

## LOAD BALANCER - allow all http https ingress and egress
resource "aws_security_group" "load_balancer_allow_all_http_https" {
  name        = "load-balancer-allow-all-http-https"
  description = "Allow all HTTP HTTPS inbound and outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.sg_tags, {
    Name = "load-balancer-allow-all-http-https"
  })
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_allow_http_ipv4_first_half" {
  security_group_id = aws_security_group.load_balancer_allow_all_http_https.id
  cidr_ipv4         = "0.0.0.0/1"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_allow_http_ipv4_second_half" {
  security_group_id = aws_security_group.load_balancer_allow_all_http_https.id
  cidr_ipv4         = "128.0.0.0/1"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_allow_https_ipv4_first_half" {
  security_group_id = aws_security_group.load_balancer_allow_all_http_https.id
  cidr_ipv4         = "0.0.0.0/1"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "load_balancer_allow_https_ipv4_second_half" {
  security_group_id = aws_security_group.load_balancer_allow_all_http_https.id
  cidr_ipv4         = "128.0.0.0/1"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "load_balancer_allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.load_balancer_allow_all_http_https.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


## ECS - allow http https ingress and egress
resource "aws_security_group" "ecs_allow_http_https" {
  name        = "ecs-allow-http-https"
  description = "Allow HTTP HTTPS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.sg_tags, {
    Name = "ecs-allow-http-https"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ecs_allow_http_ipv4" {
  security_group_id = aws_security_group.ecs_allow_http_https.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ecs_allow_https_ipv4" {
  security_group_id = aws_security_group.ecs_allow_http_https.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "ecs_allow_all_outbound" {
  security_group_id = aws_security_group.ecs_allow_http_https.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


## RDS - postgres-local-ingress
resource "aws_security_group" "postgres_local_ingress" {
  name        = "postgres-local-ingress"
  description = "Allow postgres access from VPC"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.sg_tags, {
    Name = "postgres-local-ingress"
  })
}

resource "aws_vpc_security_group_ingress_rule" "postgres_local_ingress" {
  security_group_id = aws_security_group.postgres_local_ingress.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}


## Endpoint - ECR endpoint for ECS task
resource "aws_security_group" "endpoint-ecr-for-ecs-task" {
  name        = "endpoint-ecr-for-ecs-task"
  description = "Allow HTTPS inbound traffic from ECS tasks to ECR"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.sg_tags, {
    Name = "endpoint-ecr-for-ecs-task"
  })
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_ecs_task_ingress" {
  security_group_id = aws_security_group.endpoint-ecr-for-ecs-task.id
  # referenced_security_group_id = aws_security_group.ecs_allow_http_https.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
