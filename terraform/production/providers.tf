terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.14"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.3"
    }
  }
}

provider "oci" {
  region              = "sa-saopaulo-1"
  auth                = "SecurityToken"
  config_file_profile = "DEFAULT"
}