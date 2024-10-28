
# policy to access s3 bucket

resource "aws_iam_policy" "org_logo_bucket_access_iam_policy" {
name = "${var.org_logo_bucket_id}_policy"
policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::${var.org_logo_bucket_id}/*"
            ]
        }
    ]
}
EOF
}

# policy to access s3 bucket

resource "aws_iam_policy" "demo_shortning_bucket_access_iam_policy" {
  name = "${var.demo_shortning_bucket_id}_policy"
  policy =  <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::${var.demo_shortning_bucket_id}"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::${var.demo_shortning_bucket_id}/*"
        },
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.demo_shortning_bucket_id}/*"
            ]
        },
        {
            "Sid": "Statement2",
            "Effect": "Allow",
            "Action": [
                "s3:GetLifecycleConfiguration",
                "s3:PutLifecycleConfiguration"
            ],
            "Resource": [
                "arn:aws:s3:::${var.demo_shortning_bucket_id}"
            ]
        }
    ]
}
EOF
}



resource "aws_iam_role" "ssm_role" {
  name = "SSMRoles"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# Attach SSM Managed Instance Core policy
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}