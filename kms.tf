data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_kms_key" "test_kms_key" {
  description             = "test kms key"
  deletion_window_in_days = 7

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
      {
        "Sid": "Enable IAM User Permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow GetKeyPolicy for Specific User",
        "Effect": "Allow",
        "Principal": {
    "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/<REDACTED_EMAIL>"
        },
        "Action": "kms:GetKeyPolicy",
        "Resource": "*"
      },
      {
        "Sid": "Allow GetKeyPolicy for Specific User",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_kms_grant" "test_kms_grant" {
  name              = "test-kms-grant-${var.environment}"
  key_id            = aws_kms_key.test_kms_key.id
  grantee_principal = aws_iam_role.fluentd_role.arn
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey"]
}

resource "aws_kms_grant" "test_autoscaling_kms_grant" {
  name              = "AutoScalingKMSGrant-${var.environment}"
  key_id            = aws_kms_key.test_kms_key.key_id
  grantee_principal = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  operations        = ["Encrypt", "Decrypt", "ReEncryptFrom", "ReEncryptTo", "GenerateDataKey", "DescribeKey"]
}

resource "aws_kms_grant" "test_kms_grant1" {
  name              = "test-kms-grant1"
  key_id            = aws_kms_key.test_kms_key.id
  grantee_principal = "arn:aws:iam::833576197871:user/<REDACTED_EMAIL>"
  operations        = ["Encrypt", "Decrypt", "GenerateDataKey", "DescribeKey"]
}
