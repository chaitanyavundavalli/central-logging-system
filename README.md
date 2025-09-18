# Central Logging System

A production-ready **centralized logging solution** built with Terraform, designed to integrate **AWS Cognito, Kafka, OpenSearch, and S3** for scalable log collection, processing, and analysis.

## Features
- **Terraform Infrastructure as Code (IaC)** – reproducible cloud environments
- **AWS Cognito Integration** – secure authentication and identity management
- **Kafka for Streaming** – high-throughput log ingestion pipeline
- **Amazon OpenSearch** – real-time log indexing and querying
- **S3 Archival** – cost-effective long-term log storage
- **Scalable & Resilient** – autoscaling and IAM policies for secure operations

## Project Structure
- `*.tf` → Terraform infrastructure modules
- `cognito-apis/` → API samples for authentication flows
- `kafka.tf`, `opensearch.tf` → core log processing infrastructure
- `s3.tf` → storage backend configuration

## Tech Stack
- Terraform
- AWS (Cognito, IAM, KMS, S3, OpenSearch)
- Kafka
- Python & Shell Scripts

## Use Cases
- Centralized log aggregation for microservices
- Secure log access with user authentication
- Scalable pipeline for data analytics and monitoring

## How to Use
1. Clone the repo:m
2. Update terraform.tfvars with your AWS settings.

Deploy:
terraform init
terraform apply
