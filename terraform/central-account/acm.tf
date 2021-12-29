resource "tls_private_key" "lb-self-signed" {
  count = var.lb-authentication-enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "lb-self-signed" {
  count = var.lb-authentication-enabled ? 1 : 0
  key_algorithm         = "RSA"
  private_key_pem       = tls_private_key.lb-self-signed[0].private_key_pem
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  subject {
    organization = "ACME Examples, Inc"
    common_name  = var.lb-self-signed-cert-cn
  }

}

resource "aws_acm_certificate" "lb-self-signed" {
  count            = ((var.lb-certificate-arn == "" && var.lb-authentication-enabled) ? 1 : 0)
  private_key      = tls_private_key.lb-self-signed[0].private_key_pem
  certificate_body = tls_self_signed_cert.lb-self-signed[0].cert_pem
}
