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
