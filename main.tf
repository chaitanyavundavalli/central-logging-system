module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "test-vpc"
  cidr = "10.10.0.0/23"

  azs             = ["us-east-2a", "us-east-2b"]
  private_subnets = ["10.10.0.0/25", "10.10.0.128/25"]
  public_subnets  = ["10.10.1.0/25", "10.10.1.128/25"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    environment = var.environment
  }
}
