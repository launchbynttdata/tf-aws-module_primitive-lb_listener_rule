# complete

This example creates an internal Application Load Balancer with a listener and target group, then uses the `lb_listener_rule` module to create a listener rule that forwards requests matching `/api/*` to the target group.

## Usage

```hcl
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
  name               = module.resource_names["alb"].standard
  internal           = true
  load_balancer_type = "application"
  subnets            = [aws_subnet.a.id, aws_subnet.b.id]
  tags               = var.tags
}

resource "aws_lb_target_group" "example" {
  name     = module.resource_names["tg"].standard
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
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_lb_listener_rule"></a> [lb\_listener\_rule](#module\_lb\_listener\_rule) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_lb.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_subnet.a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family for resource naming. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service for resource naming. | `string` | `"lbrule"` | no |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment class for resource naming. | `number` | `0` | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Environment instance number for resource naming. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Resource instance number for resource naming. | `number` | `0` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of resource names to create via the resource naming module. | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | <pre>{<br/>  "alb": {<br/>    "max_length": 32,<br/>    "name": "alb"<br/>  },<br/>  "tg": {<br/>    "max_length": 32,<br/>    "name": "tg"<br/>  }<br/>}</pre> | no |
| <a name="input_listener_arn"></a> [listener\_arn](#input\_listener\_arn) | The ARN of the listener to which to attach the rule. If not specified, the listener created by this example is used. | `string` | `null` | no |
| <a name="input_priority"></a> [priority](#input\_priority) | The priority for the rule between 1 and 50000. | `number` | `null` | no |
| <a name="input_action"></a> [action](#input\_action) | List of action blocks for the listener rule. If not specified, defaults to forwarding to the target group created by this example. | `any` | `null` | no |
| <a name="input_condition"></a> [condition](#input\_condition) | List of condition blocks for the listener rule. | <pre>list(object({<br/>    host_header = optional(object({<br/>      values       = optional(list(string))<br/>      regex_values = optional(list(string))<br/>    }))<br/>    http_header = optional(list(object({<br/>      http_header_name = string<br/>      values           = optional(list(string))<br/>      regex_values     = optional(list(string))<br/>    })))<br/>    http_request_method = optional(object({<br/>      values = list(string)<br/>    }))<br/>    path_pattern = optional(object({<br/>      values       = optional(list(string))<br/>      regex_values = optional(list(string))<br/>    }))<br/>    query_string = optional(list(object({<br/>      key   = optional(string)<br/>      value = string<br/>    })))<br/>    source_ip = optional(object({<br/>      values = list(string)<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_transform"></a> [transform](#input\_transform) | Configuration block that defines the transform to apply to requests matching this rule. | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the resource. | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the listener rule will be managed. Defaults to the region set in the provider configuration. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the listener rule (same as the ARN). |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the listener rule. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags. |
| <a name="output_listener_arn"></a> [listener\_arn](#output\_listener\_arn) | The ARN of the listener used by this example. |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | The ARN of the target group used by this example. |
<!-- END_TF_DOCS -->
