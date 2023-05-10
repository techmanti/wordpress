# terraform aws data hosted zone
data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

# create a record set in route 53
# terraform aws route 53 record

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.record_name
  type    = "A"
    
    alias {
      name = var.application_load_balancer_dns_name
      zone_id = var.application_load_balancer_zone_id
      evaluate_target_health = true

    }
}

resource "aws_route53_record" "record_name" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = ""
  type    = "A"
    
    alias {
      name = var.application_load_balancer_dns_name
      zone_id = var.application_load_balancer_zone_id
      evaluate_target_health = true

    }
}