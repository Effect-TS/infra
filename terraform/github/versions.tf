terraform {
  required_version = ">= 1.3"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.41.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.0.0"
    }
  }
}
