locals {
  main_tags = {
    Environment = "preprod"
    Project     = "omega"
    Component   = "network"
    IaaC        = "terraform"
  }
}


############
## VPC
############
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"
  
  name = "omega-preprod"
  cidr = "10.0.0.0/16"

  enable_nat_gateway  = false
  # single_nat_gateway  = true # I think natgateway won't be needed here
  # reuse_nat_ips       = true
  # external_nat_ip_ids = [aws_eip.omega-preprod.id]

  azs             = ["eu-north-1a", "eu-north-1b"]
  # Since I am not using NATGateway it is recommender (required?) to use
  # intra_subnets instead of private_subnets
  intra_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  manage_default_security_group = false
  manage_default_route_table = false
  manage_default_network_acl = false
  enable_dns_hostnames = true # required to create VPC endpoints

  tags = local.sg_tags
}


############
## VPC endpoints
############

# ECR API Endpoint
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [ aws_security_group.endpoint-ecr-for-ecs-task.id ]
  subnet_ids          = module.vpc.intra_subnets
  private_dns_enabled = true

  tags = merge(local.sg_tags, {
    Name = "endpoint-ecr-api"
  })
}

# ECR Docker Registry Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [ aws_security_group.endpoint-ecr-for-ecs-task.id ]
  subnet_ids          = module.vpc.intra_subnets
  private_dns_enabled = true

  tags = merge(local.sg_tags, {
    Name = "endpoint-ecr-docker-registry"
  })
}

# Logs (cloudwatch) Endpoint
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [ aws_security_group.endpoint-ecr-for-ecs-task.id ]
  subnet_ids          = module.vpc.intra_subnets
  private_dns_enabled = true

  tags = merge(local.sg_tags, {
    Name = "endpoint-logs"
  })
}

## SSM Endpoints
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.intra_subnets
  security_group_ids  = [ aws_security_group.endpoint-ecr-for-ecs-task.id ]
  private_dns_enabled = true

  tags = merge(local.sg_tags, {
    Name = "endpoint-ssm"
  })
}

## EC2 Messages Endpoint
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.intra_subnets
  security_group_ids  = [ aws_security_group.endpoint-ecr-for-ecs-task.id ]
  private_dns_enabled = true

  tags = merge(local.sg_tags, {
    Name = "endpoint-ec2messages"
  })
}

## SSM Messages Endpoint
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.intra_subnets
  security_group_ids  = [ aws_security_group.endpoint-ecr-for-ecs-task.id ]
  private_dns_enabled = true

  tags = merge(local.sg_tags, {
    Name = "endpoint-ssmmessages"
  })
}

# S3 Gateway Endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc.intra_route_table_ids

  tags = merge(local.sg_tags, {
    Name = "endpoint-s3"
  })
}
