
resource "aws_s3_object" "webauthn_env" {
  bucket = var.env_file_bucket_id
  key    = "${var.environment}-web-authn.env"
  content = <<-EOT
RP_ID=
EXPECTED_ORIGINS=
ENABLE_CONFORMANCE=false
ENABLE_HTTPS=false
  EOT
}
