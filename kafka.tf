resource "aws_cloudwatch_log_group" "kafka_log_group" {
  name = "/aws/kafka"

  tags = {
    environment = var.environment
    service     = "cloudwatch"
  }
}

resource "aws_msk_configuration" "kafka_config" {
  kafka_versions = ["3.4.0"]
  name           = "kafka-configuration-${var.environment}"

  server_properties = <<-PROPERTIES
    auto.create.topics.enable = true
    delete.topic.enable = true
  PROPERTIES
}

resource "aws_msk_cluster" "test_kafka_cluster" {
  cluster_name           = "test-kafka-cluster-${var.environment}"
  kafka_version          = "3.4.0"
  number_of_broker_nodes = 2

  broker_node_group_info {
    instance_type   = var.kafka_intance_type
    client_subnets  = module.vpc.private_subnets
    security_groups = [aws_security_group.test_kafka_sg.id]
    storage_info {
      ebs_storage_info {
        volume_size = var.kafka_volume_size
      }
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.kafka_config.arn
    revision = aws_msk_configuration.kafka_config.latest_revision
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.test_kms_key.arn
    encryption_in_transit {
      client_broker = "PLAINTEXT"
    }
  }
  client_authentication {
    unauthenticated = true
    sasl {
      iam   = false
      scram = false
    }
    #  tls {

    #  }
  }
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.kafka_log_group.name
      }
    }
  }
  tags = {
    environment = var.environment
    service     = "kafka"
  }
}

# aws_mskconnect_connector.msk_s3_connector:
resource "aws_mskconnect_connector" "msk_s3_connector" {
  connector_configuration = {
    "connector.class"      = "io.confluent.connect.s3.S3SinkConnector"
    "flush.size"           = "1"
    "format.class"         = "io.confluent.connect.s3.format.json.JsonFormat"
    "partitioner.class"    = "io.confluent.connect.storage.partitioner.DefaultPartitioner"
    "s3.bucket.name"       = aws_s3_bucket.test_s3_bucket.id
    "s3.region"            = "${data.aws_region.current.name}"
    "schema.compatibility" = "NONE"
    "storage.class"        = "io.confluent.connect.s3.storage.S3Storage"
    "tasks.max"            = "2"
    "topics"               = "log-messages"
    "topics.dir"           = var.topics_dir
  }
  kafkaconnect_version       = "2.7.1"
  name                       = "test-kafka-s3-${var.environment}"
  service_execution_role_arn = aws_iam_role.test_kafka_s3.arn

  capacity {
    autoscaling {
      max_worker_count = 2
      mcu_count        = 1
      min_worker_count = 1

      scale_in_policy {
        cpu_utilization_percentage = 20
      }

      scale_out_policy {
        cpu_utilization_percentage = 80
      }
    }
  }

  kafka_cluster {
    apache_kafka_cluster {
      bootstrap_servers = aws_msk_cluster.test_kafka_cluster.bootstrap_brokers

      vpc {
        security_groups = [
          aws_security_group.test_kafka_sg.id,
        ]
        subnets = [
          module.vpc.private_subnets[0],
          module.vpc.private_subnets[1],
        ]
      }
    }
  }

  kafka_cluster_client_authentication {
    authentication_type = "NONE"
  }

  kafka_cluster_encryption_in_transit {
    encryption_type = "TLS"
  }

  log_delivery {
    worker_log_delivery {
      cloudwatch_logs {
        enabled   = true
        log_group = "/aws/kafka"
      }
    }
  }

  plugin {
    custom_plugin {
      arn      = aws_mskconnect_custom_plugin.kafka_s3_custom_plugin.arn
      revision = 1
    }
  }
}

# aws_s3_object.kafka_s3_custom_plugin:
resource "aws_s3_object" "kafka_s3_custom_plugin" {
  bucket             = aws_s3_bucket.test_s3_bucket.id
  bucket_key_enabled = false
  key                = "confluentinc-kafka-connect-s3-10.5.5.zip"
  kms_key_id         = aws_kms_key.test_kms_key.arn
  source             = "${path.module}/confluentinc-kafka-connect-s3-10.5.5.zip"
}

# aws_mskconnect_custom_plugin.kafka_s3_custom_plugin:
resource "aws_mskconnect_custom_plugin" "kafka_s3_custom_plugin" {
  content_type = "ZIP"
  name         = "test-kafka-s3-custom-plugin-${var.environment}"

  location {
    s3 {
      bucket_arn = aws_s3_bucket.test_s3_bucket.arn
      file_key   = "confluentinc-kafka-connect-s3-10.5.5.zip"
    }
  }
}
