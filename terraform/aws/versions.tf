terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.20.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.3.2"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.11.1"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "= 0.1.11"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "= 3.1.0"
    }

    github = {
      source  = "integrations/github"
      version = "= 4.12.0"
    }
  }

  required_version = "> 0.14"
}

