output "target_group_arn" {
  value       = "${aws_alb_target_group.target_group.arn}"
  description = "The ARN of the target group"
}

output "dns_name" {
  value       = "${local.dns_name}.${var.dns_domain}"
  description = "The DNS name for the service."
}
