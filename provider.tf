terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.20.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
    access_key = "AKIASU5ECV7IHCIG4CWC"
    secret_key = "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"
}
