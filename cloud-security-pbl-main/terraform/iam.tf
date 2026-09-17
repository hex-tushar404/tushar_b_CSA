# ==============================
# IAM Groups
# ==============================

resource "aws_iam_group" "admins" {
  name = "CloudSecurity-Admins"
}

resource "aws_iam_group" "developers" {
  name = "CloudSecurity-Developers"
}

resource "aws_iam_group" "auditors" {
  name = "CloudSecurity-Auditors"
}


# ==============================
# Developer Least-Privilege Policy
# ==============================

resource "aws_iam_policy" "developer_policy" {
  name        = "CloudSecurity-Developer-Policy"
  description = "Limited permissions for application developers"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = [
          aws_s3_bucket.application_data.arn,
          "${aws_s3_bucket.application_data.arn}/*"
        ]
      }
    ]
  })
}


# Attach Developer Policy to Developers group

resource "aws_iam_group_policy_attachment" "developer_policy_attachment" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.developer_policy.arn
}


# ==============================
# Auditor Read-Only Policy
# ==============================

resource "aws_iam_policy" "auditor_policy" {
  name        = "CloudSecurity-Auditor-Policy"
  description = "Read-only permissions for security auditing"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:Describe*",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:GetObject",
          "iam:Get*",
          "iam:List*"
        ]

        Resource = "*"
      }
    ]
  })
}


# Attach Auditor Policy

resource "aws_iam_group_policy_attachment" "auditor_policy_attachment" {
  group      = aws_iam_group.auditors.name
  policy_arn = aws_iam_policy.auditor_policy.arn
}

# ==============================
# Admin MFA Enforcement
# ==============================

resource "aws_iam_group_policy" "admin_mfa_enforcement" {
  name  = "CloudSecurity-Admin-MFA-Required"
  group = aws_iam_group.admins.name

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "DenyAllActionsWithoutMFA"
        Effect = "Deny"

        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ListUsers",
          "sts:GetSessionToken"
        ]

        Resource = "*"

        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# ==============================
# EC2 IAM Role
# ==============================

resource "aws_iam_role" "ec2_s3_role" {
  name = "CloudSecurity-EC2-S3-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "CloudSecurity-EC2-S3-Role"
  }
}
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "CloudSecurity-EC2-S3-Access"
  role = aws_iam_role.ec2_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ListApplicationBucket"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.application_data.arn
      },

      {
        Sid    = "AccessApplicationObjects"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.application_data.arn}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "CloudSecurity-EC2-Instance-Profile"
  role = aws_iam_role.ec2_s3_role.name
}