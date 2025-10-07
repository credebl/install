
resource "aws_s3_object" "webauthn_env" {
  bucket = var.env_file_bucket_id
  key    = "${var.environment}-WEB_AUTHN.env"
  content = <<-EOT
RP_ID=${var.alb_details["api-gateway"].dns} 
EXPECTED_ORIGINS=http://${var.alb_details["api-gateway"].dns} 
ENABLE_CONFORMANCE=false
ENABLE_HTTPS=false
  EOT
}
