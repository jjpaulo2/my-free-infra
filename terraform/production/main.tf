locals {
  os = {
    name    = "Canonical Ubuntu"
    version = "24.04 Minimal"
  }
}

module "network" {
  source = "../modules/virtual-network"

  compartment_id = var.compartment_id
  display_name   = "cluster-network"
}

module "node_0" {
  source = "../modules/linux-machine"

  display_name   = "cluster-node-0"
  os             = local.os
  compartment_id = var.compartment_id
  subnet_id      = module.network.subnet_id
  vcn_id         = module.network.vcn_id
}
