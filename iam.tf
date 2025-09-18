# IAM Role for Fluentd
resource "aws_iam_role" "fluentd_role" {
  name               = "fluentd-role-${var.environment}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM Instance Profile for Fluentd
resource "aws_iam_instance_profile" "fluentd_profile" {
  name = "fluentd-profile-${var.environment}"
  role = aws_iam_role.fluentd_role.name
}

# IAM Role Policy for Fluentd to access S3
resource "aws_iam_role_policy" "fluentd_s3_policy" {
  name   = "fluentd-s3-policy-${var.environment}"
  role   = aws_iam_role.fluentd_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Put*",
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
  "Resource": ["${aws_s3_bucket.test_s3_bucket.arn}","${aws_s3_bucket.test_s3_bucket.arn}/*"]
    }
  ]
}
EOF
}

# IAM Role Policy for Fluentd to access KMS
resource "aws_iam_role_policy" "fluentd_kms_policy" {
  name   = "fluentd-kms-policy-${var.environment}"
  role   = aws_iam_role.fluentd_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:GenerateDataKey*",
        "kms:Rencrypt*"
      ],
      "Effect": "Allow",
  "Resource": "${aws_kms_key.test_kms_key.arn}"
    }
  ]
}
EOF
}

# IAM Role Policy for Fluentd to access Kafka (MSK)
resource "aws_iam_role_policy" "fluentd_msk_policy" {
  name   = "fluentd-msk-policy-${var.environment}"
  role   = aws_iam_role.fluentd_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "kafka:Connect",
        "kafka:AlterCluster",
        "kafka:DescribeCluster",
        "kafka:*Topic*",
        "kafka:WriteData",
        "kafka:ReadData",
        "kafka:AlterGroup",
        "kafka:DescribeGroup"
      ],
      "Effect": "Allow",
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role" "test_kafka_s3" {
  name               = "test-kafka-s3-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.assume-role-policy.json
}


data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "kafkaconnect.amazonaws.com",
        "osis-pipelines.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "test_kafka_s3_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonMSKConnectReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonMSKFullAccess",
    "arn:aws:iam::aws:policy/AmazonOpenSearchIngestionFullAccess",
    "arn:aws:iam::aws:policy/AmazonOpenSearchIngestionReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess",
    "arn:aws:iam::aws:policy/AmazonOpenSearchServiceReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
  ])
  role       = aws_iam_role.test_kafka_s3.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "KMS-policy" {
  name   = "KMS-policy-${var.environment}"
  role   = aws_iam_role.test_kafka_s3.name
  policy = data.aws_iam_policy_document.KMS-policy.json
}

data "aws_iam_policy_document" "KMS-policy" {
  statement {
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "opensearch-policy" {
  name   = "opensearch-policy-${var.environment}"
  role   = aws_iam_role.test_kafka_s3.name
  policy = data.aws_iam_policy_document.opensearch-policy.json
}

data "aws_iam_policy_document" "opensearch-policy" {
  statement {
    actions = [
      "opensearch:ESHttpGet",
      "opensearch:ESHttpHead"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "cluster:monitor/state"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "test-kafka-s3-policy" {
  name   = "test-kafka-s3-policy-${var.environment}"
  role   = aws_iam_role.test_kafka_s3.name
  policy = data.aws_iam_policy_document.test-kafka-s3-policy.json
}

data "aws_iam_policy_document" "test-kafka-s3-policy" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:Abort*",
      "s3:Put*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "test-cognito-policy" {
  name   = "test-cognito-policy-${var.environment}"
  role   = aws_iam_role.cognito_test_role.name
  policy = data.aws_iam_policy_document.test-cognito-policy.json
}

resource "aws_iam_role" "cognito_test_role" {
  name = "cognito-test-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "cognito-idp.amazonaws.com"
        }
      }
    ]
  })
}

data "aws_iam_policy_document" "test-cognito-policy" {
  statement {
    actions = [
      "sns:publish",
      "sts:AssumeRole"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy" "ssm_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.fluentd_role.name
  policy_arn = data.aws_iam_policy.ssm_policy.arn
}
