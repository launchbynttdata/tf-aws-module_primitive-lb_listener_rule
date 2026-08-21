data "aws_region" "current" {}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length
  region                  = join("", split("-", data.aws_region.current.id))
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags       = var.tags
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.example.id
  tags   = var.tags
}

resource "aws_subnet" "a" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${data.aws_region.current.id}a"
  tags              = var.tags
}

resource "aws_subnet" "b" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${data.aws_region.current.id}b"
  tags              = var.tags
}

resource "aws_lb" "example" {
  name               = module.resource_names["alb"].minimal_random_suffix
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.a.id, aws_subnet.b.id]
  tags               = var.tags
}

resource "aws_lb_target_group" "example" {
  name     = module.resource_names["tg"].minimal_random_suffix
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id
  tags     = var.tags
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }

  tags = var.tags
}

locals {
  listener_arn = var.listener_arn != null ? var.listener_arn : aws_lb_listener.example.arn
  action = var.action != null ? var.action : [
    {
      type             = "forward"
      target_group_arn = aws_lb_target_group.example.arn
    }
  ]
}

module "lb_listener_rule" {
  source = "../.."

  listener_arn = local.listener_arn
  priority     = var.priority
  action       = local.action
  condition    = var.condition
  transform    = var.transform
  tags         = var.tags
  region       = var.region
}
