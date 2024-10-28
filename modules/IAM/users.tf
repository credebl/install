# organization logon bucket access user
resource "aws_iam_user" "org_logo_iam_user" {

  name = "${var.org_logo_bucket_id}_user"

  tags = {
    use = "to access demo shortning bucket"
  }
}

resource "aws_iam_access_key" "org_logo_iam_user_access_key" {
  user = aws_iam_user.org_logo_iam_user.name
}


resource "aws_iam_policy_attachment" "org_logo_iam_user_policy_attach" {
  name       = "org_logo_iam_user-attachment"
  users      = [aws_iam_user.org_logo_iam_user.name]
  policy_arn = aws_iam_policy.org_logo_bucket_access_iam_policy.arn
}



# demo shortning user

resource "aws_iam_user" "demo_shortning_iam_user" {
  name = "${var.demo_shortning_bucket_id}_user"

  tags = {
    use = "to access demo shortning bucket"
  }
}

resource "aws_iam_access_key" "demo_shortning_iam_user_access_key" {
  user = aws_iam_user.demo_shortning_iam_user.name
}


resource "aws_iam_policy_attachment" "demo_shortning_iam_user_policy_attach" {
  name       = "demo_shortning_iam_user-attachment"
  users      = [aws_iam_user.demo_shortning_iam_user.name]
  policy_arn = aws_iam_policy.demo_shortning_bucket_access_iam_policy.arn
}