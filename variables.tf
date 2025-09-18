# variable "vpc_id" {
#   description = "VPC ID"
# }

# variable "public_subnet_ids" {
#   description = "Public Subnet Ids"
# }

# variable "private_subnet_ids" {
#   description = "privatre subnet ids"
# }

# variable "acm_cert_arn" {
#   description = "acm certificate"
# }

variable "environment" {
  description = "environment"
  default     = "dev"
}

variable "s3_bucket_name" {
  description = "S3 Bucket"
}

variable "ami_name" {
  description = "ami name"
}

variable "fluentd_instance_type" {
  description = "fluentd instance type"
}
# variable "opensearch_instance_type" {
#   description = "opensearch instance type"
#  }

variable "key_name" {
  description = "key name"
}

variable "desired_capacity" {
  description = "desired capacity"
}

variable "max_size" {
  description = "max size"
}

variable "min_size" {
  description = "min size"
}
variable "volume_size" {
  description = "Volume size"
}

variable "kafka_intance_type" {
  description = "kafka intance type"
}

variable "kafka_volume_size" {
  description = "kafka volume size"
}

variable "test_nlb_name" {
  description = "test nlb name"
}

#  variable "certificate_arn" {
#    description = "certificate arn"
#  }

variable "topics_dir" {
  description = "topics dir"
}
