s3_bucket_name = "test-s3-logging-ohio-prod"
environment    = "prod"

ami_name              = "ami-024b247cbe7eb933d"
fluentd_instance_type = "t3.small"
kafka_intance_type    = "kafka.t3.small"
kafka_volume_size     = 100
key_name              = "test-ohio-prod"
desired_capacity      = 2
min_size              = 2
max_size              = 2
volume_size           = 20
test_nlb_name         = "test-fluentd-nlb-prod"
#certificate_arn = "arn:aws:acm:us-east-1:833576197871:certificate/999dc115-692a-49c6-a7b5-a6d1b005c88a"
topics_dir = "topics-prod"
