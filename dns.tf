# Luis merino : Despliegue en aws con terraform y ansible
# 
# Configuracion del DNS , la hosted zone para el dominio debe de existir
# LO vamos a hacer con route53 , si es otro registra necesitas
# autentificar de firma manual el cert

data "aws_route53_zone" "dns" {
  provider = aws.region-master
  name     = var.dns-name
}

# creamos el registro en la hosted zone para la validacion del certificado del acm
resource "aws_route53_record" "cert_validation" {
  provider = aws.region-master
  for_each = {
    for val in aws_acm_certificate.jenkins-lb-https.domain_validation_options : val.domain_name => {
      name   = val.resource_record_name
      record = val.resource_record_value
      type   = val.resource_record_type
    }
  }
  name    = each.value.name
  records = [each.value.record]
  ttl     = 60
  type    = each.value.type
  zone_id = data.aws_route53_zone.dns.zone_id
}

# definimos el alias record de forma que el traffico que venga hacia el dominio se mande al lb
resource "aws_route53_record" "jenkins" {
  provider = aws.region-master
  zone_id  = data.aws_route53_zone.dns.zone_id
  name     = join(".", ["jenkins", data.aws_route53_zone.dns.name])
  type     = "A"
  alias {
    name                   = aws_lb.application_lb.dns_name
    zone_id                = aws_lb.application_lb.zone_id
    evaluate_target_health = true
  }
}