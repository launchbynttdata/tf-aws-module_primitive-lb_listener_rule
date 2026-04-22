output "id" {
  description = "The ID of the listener rule (same as the ARN)."
  value       = module.lb_listener_rule.id
}

output "arn" {
  description = "The ARN of the listener rule."
  value       = module.lb_listener_rule.arn
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags."
  value       = module.lb_listener_rule.tags_all
}

output "listener_arn" {
  description = "The ARN of the listener used by this example."
  value       = aws_lb_listener.example.arn
}

output "target_group_arn" {
  description = "The ARN of the target group used by this example."
  value       = aws_lb_target_group.example.arn
}
