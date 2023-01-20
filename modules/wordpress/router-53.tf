# get hosted zone details
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
  ttl     = 300
  records = [aws_eip.eip.public_ip]
}