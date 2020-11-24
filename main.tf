terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    random = {
      source = "hashicorp/random"
    }

  }
}

provider "aws" {
  //region = "eu-north-1"
  region = "us-east-1"
}
