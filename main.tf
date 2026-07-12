# 1. TERRAFORM SETTINGS
# Configures the required Terraform version and provider source/version.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. PROVIDER CONFIGURATION
# Configures the target cloud platform and region.
provider "aws" {
  region = var.aws_region
}

# 3. INPUT VARIABLES
# Allows customization of settings without modifying the main code blocks.
variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Value for the Name tag of the EC2 instance."
  type        = string
  default     = "ExampleWebServer"
}

# 4. DATA SOURCES
# Queries cloud provider APIs for existing infrastructure information.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical ID for Ubuntu
}

# 5. RESOURCES
# The physical blocks of infrastructure to create.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "web" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "web-subnet"
  }
}

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web.id

  tags = {
    Name = var.instance_name
  }
}

# 6. OUTPUT VALUES
# Exposes information about resources to the CLI or other configurations.
output "instance_public_ip" {
  description = "The public IP address of the newly created web server."
  value       = aws_instance.web_server.public_ip
}
