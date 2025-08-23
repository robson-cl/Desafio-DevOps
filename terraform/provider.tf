terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  # Backend local, opcional
  # backend "local" { path = "terraform.tfstate" }
}

provider "aws" {
  region = var.aws_region
}
