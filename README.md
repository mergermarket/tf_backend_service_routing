Description
-----------

This module creates the DNS and routing rule for a backend service. It's an
opinionated module that forms the DNS name from the `env` (environment name),
`name` (short name for the service - typically with the "-service" suffix
removed) and `domain`.

For the live environment this will be:

    name.domain

For the non-live environments this will be:

    env-name.dev.domain

This is intended for use in a backend router component (i.e. one created from
https://github.com/mergermarket/backend-router-boilerplate).

Usage
-----

Add this to the bottom of the `infra/main.tf` file in your backend router for
each service:

    # Results in DNS and routing for this in live:
    #   my-example.mmgapi.net
    # ...or this in a non-live environment (e.g. aslive):
    #   aslive-my-example.dev.mmgapi.net

    module "tf_backend_service_routing" "notifications-profile-matching-service" {
        source           = "github.com/mergermarket/tf_backend_service_routing"
        env              = "${var.env}"
        name             = "notifications-profile-matching"
        domain           = "mmgapi.net"
        priority         = "100"
        target_group_arn = "${var.target_groups["notifications-profile-matching-service"]}"
        alb_listener_arn = "${module.backend_router.alb_listener_arn}" 
        alb_dns_name     = "${module.backend_router.alb_dns_name}"
    }

Then put the ARN for the target group of your service in each environment into
`config/qa.json`, `config/aslive.json`, ...:

    {
        "target_groups": {
            "notifications-profile-matching-service": "arn:of:the:qa:notifications-profile-matching-service:target:group"
        }
    }

