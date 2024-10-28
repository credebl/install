resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMInstanceProfiles"
  role = var.ssm_role_name
}
