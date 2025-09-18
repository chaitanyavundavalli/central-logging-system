resource "aws_security_group" "test_fluentd_nlb_sg" {
  name        = "test-fulentd-nlb-sg-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from Public"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "test-fluentd-nlb-sg-${var.environment}"
    environment = var.environment
  }
}

resource "aws_security_group" "test_fluentd_sg" {
  name        = "test-fulentd-sg-${var.environment}"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Fluentd Access from same VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "test-fluentd-sg-${var.environment}"
    environment = var.environment
  }
}

resource "aws_security_group" "test_kafka_sg" {
  name        = "test-kafka-sg-${var.environment}"
  description = "Allow kafka inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "kafka Access from same VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }

  ingress {
    description = "kafka Access from same VPC"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }

  ingress {
    description = "kafka Access from same VPC"
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }

  ingress {
    description = "kafka Access from same VPC"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }

  ingress {
    description = "kafka Access from same VPC"
    from_port   = 9094
    to_port     = 9094
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }

  ingress {
    description = "kafka Access from same VPC"
    from_port   = 9096
    to_port     = 9096
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }

  ingress {
    description = "kafka Access from same VPC"
    from_port   = 9098
    to_port     = 9098
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }

  ingress {
    description = "kafka Access from same VPC"
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "test-kafka-sg-${var.environment}"
    environment = var.environment
  }
}
