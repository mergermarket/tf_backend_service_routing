data "aws_route53_zone" "dns_domain" {
  name = "${data.template_file.domain.rendered}"
}

data "template_file" "domain" {
  template = "$${env == "live" ? "$${dns_domain}" : "dev.$${dns_domain}"}."

  vars {
    env        = "${var.env}"
    dns_domain = "${var.dns_domain}"
  }
}

data "template_file" "fqdn" {
  template = "$${env == "live" ? "$${name}.$${dns_domain}" : "$${env}-$${name}.dev.$${dns_domain}"}"

  vars {
    env        = "${var.env}"
    name       = "${var.dns_name != "" ? var.dns_name : replace(var.component_name, "/-service$/", "")}"
    dns_domain = "${var.dns_domain}"
  }
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
    values = ["${data.template_file.fqdn.rendered}"]
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}

resource "aws_alb_target_group" "target_group" {
  name = "${replace(replace("${var.env}-${var.component_name}", "/(.{0,32}).*/", "$1"), "/^-+|-+$/", "")}"

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
}

resource "aws_route53_record" "dns_record" {
  zone_id = "${data.aws_route53_zone.dns_domain.zone_id}"
  name    = "${data.template_file.fqdn.rendered}"

  type    = "CNAME"
  records = ["${var.alb_dns_name}"]
  ttl     = "${var.ttl}"

  depends_on = ["aws_alb_listener_rule.rule"]
}
