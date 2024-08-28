terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

  }
}

provider "aws" {
  default_tags {
    tags = {
      Environment = "Prod"
      Owner       = "myCompany"
      Project     = "DFE"
    }
  }
  profile = "terraform"
  region  = "ap-southeast-1"
}