terraform {
  cloud {
    organization = "mark-hendrix-projects"

    workspaces {
      name = "mark-hendrix-dot-com"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}

provider "aws" {}

provider "cloudflare" {}

