resource "aws_elasticsearch_domain" "test_logging" {
  access_policies = jsonencode({
    Statement = [
      {
        Action = "es:*"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Resource = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/test-${var.environment}-logging/*"
      },
    ]
    Version = "2012-10-17"
  })

  advanced_options = {
    "indices.fielddata.cache.size"        = "20"
    "indices.query.bool.max_clause_count" = "1024"
  }

  domain_name           = "test-${var.environment}-logging"
  elasticsearch_version = "OpenSearch_2.9"

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = "A_Strong_Password_123!"
    }
  }

  auto_tune_options {
    desired_state       = "ENABLED"
    rollback_on_disable = "NO_ROLLBACK"
  }

  cluster_config {
    dedicated_master_count   = 0
    dedicated_master_enabled = false
    instance_count           = 2
    instance_type            = "m6g.large.elasticsearch"
    warm_count               = 2
    warm_enabled             = false
    zone_awareness_enabled   = true

    cold_storage_options {
      enabled = false
    }

    zone_awareness_config {
      availability_zone_count = 2
    }
  }

  domain_endpoint_options {
    custom_endpoint_enabled = false
    enforce_https           = true
    tls_security_policy     = "Policy-Min-TLS-1-0-2019-07"
  }

  ebs_options {
    ebs_enabled = true
    iops        = 3000
    throughput  = 125
    volume_size = 100
    volume_type = "gp3"
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.test_kms_key.arn
  }

  node_to_node_encryption {
    enabled = true
  }

  snapshot_options {
    automated_snapshot_start_hour = 0
  }
}
