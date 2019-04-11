locals {
  dns_name = "${var.override_dns_name != "" ? var.override_dns_name : replace(var.component_name, "/-service$/", "")}"
}

data "aws_route53_zone" "dns_domain" {
  name = "${var.dns_domain}"
}

resource "aws_alb_listener_rule" "rule" {
  listener_arn = "${var.alb_listener_arn}"
  priority     = "${var.priority}"

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.target_group.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${local.dns_name}.${var.dns_domain}"]
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}

locals {
  old_target_group_name = "${replace(replace("${var.env}-${var.component_name}", "/(.{0,32}).*/", "$1"), "/^-+|-+$/", "")}"

  target_group_name_hash    = "${base64encode(base64sha256("${var.env}-${var.component_name}"))}"
  target_group_name_postfix = "${replace(replace("${local.target_group_name_hash}", "/(.{0,12}).*/", "$1"), "/^-+|-+$/", "")}"
  target_group_name_prefix  = "${replace(replace("${var.env}-${var.component_name}", "/(.{0,20}).*/", "$1"), "/^-+|-+$/", "")}"
  target_group_name         = "${local.target_group_name_prefix}${local.target_group_name_postfix}"
}

resource "aws_alb_target_group" "target_group" {
  name = "${var.hash_target_group_name ? local.target_group_name : local.old_target_group_name}"

  # port will be set dynamically, but for some reason AWS requires a value
  port                 = "31337"
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    interval            = "${var.health_check_interval}"
    path                = "${var.health_check_path}"
    timeout             = "${var.health_check_timeout}"
    healthy_threshold   = "${var.health_check_healthy_threshold}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    matcher             = "${var.health_check_matcher}"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    component = "${var.component_name}"
    env       = "${var.env}"
    service   = "${var.env}-${var.component_name}"
  }
}

resource "aws_route53_record" "dns_record" {
  zone_id = "${data.aws_route53_zone.dns_domain.zone_id}"
  name    = "${var.env}-${local.dns_name}.${var.dns_domain}"

  type            = "CNAME"
  records         = ["${var.alb_dns_name}"]
  ttl             = "${var.ttl}"
  allow_overwrite = "${var.allow_overwrite}"

  depends_on = ["aws_alb_listener_rule.rule"]
}
