terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

# Uses the GITHUB_TOKEN environment variable
provider "github" {}