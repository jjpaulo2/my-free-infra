locals {
  os = {
    name    = "Canonical Ubuntu"
    version = "24.04 Minimal"
  }
}

module "network" {
  source = "../modules/virtual-network"

  compartment_id  = var.compartment_id
  display_name    = "cluster-network"
  allow_public_ip = true
}

module "node_0" {
  source = "../modules/linux-machine"

  display_name     = "cluster-node-0"
  os               = local.os
  compartment_id   = var.compartment_id
  subnet_id        = module.network.subnet_id
  vcn_id           = module.network.vcn_id
  assign_public_ip = true
}

module "node_1" {
  source = "../modules/linux-machine"

  display_name     = "cluster-node-1"
  os               = local.os
  compartment_id   = var.compartment_id
  subnet_id        = module.network.subnet_id
  vcn_id           = module.network.vcn_id
  assign_public_ip = true
}
