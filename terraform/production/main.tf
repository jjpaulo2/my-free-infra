data "http" "my_ip" {
  url = "https://api.ipify.org"
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
  compartment_id   = var.compartment_id
  subnet_id        = module.network.subnet_id
  vcn_id           = module.network.vcn_id
  assign_public_ip = true

  ingress_tcp_rules = [
    {
      port = "22"
      cidr = "${data.http.my_ip.response_body}/32"
    },
    {
      port = "80"
      cidr = "0.0.0.0/0"
    },
    {
      port = "443"
      cidr = "0.0.0.0/0"
    }
  ]
}

module "node_1" {
  source = "../modules/linux-machine"

  display_name     = "cluster-node-1"
  compartment_id   = var.compartment_id
  subnet_id        = module.network.subnet_id
  vcn_id           = module.network.vcn_id
  assign_public_ip = true

  ingress_tcp_rules = [
    {
      port = "22"
      cidr = "${data.http.my_ip.response_body}/32"
    },
    {
      port = "9001" # Portainer Agent
      cidr = "${module.node_0.private_ip}/32"
    }
  ]
}

module "node_heavy_0" {
  source = "../modules/linux-machine"

  display_name     = "cluster-node-heavy-0"
  shape            = "VM.Standard.E2.4"
  compartment_id   = var.compartment_id
  subnet_id        = module.network.subnet_id
  vcn_id           = module.network.vcn_id
  assign_public_ip = true

  ingress_tcp_rules = [
    {
      port = "22"
      cidr = "${data.http.my_ip.response_body}/32"
    },
    {
      port = "9001" # Portainer Agent
      cidr = "${module.node_0.private_ip}/32"
    },
    {
      port = "25565" # Minecraft
      cidr = "0.0.0.0/0"
    }
  ]

  ingress_udp_rules = [
    {
      port = "2456" # Valheim
      cidr = "0.0.0.0/0"
    },
    {
      port = "2457" # Valheim
      cidr = "0.0.0.0/0"
    }
  ]
}

resource "oci_identity_dynamic_group" "managers" {
  compartment_id = var.compartment_id
  name           = "cluster-managers"
  description    = "Machines that can manage the cluster"
  matching_rule  = "Any {instance.id = '${module.node_0.instance_id}'}"
}

resource "oci_identity_policy" "managers" {
  compartment_id = var.compartment_id
  name           = "cluster-managers"
  description    = "Allow manager dynamic group to manage the whole cluster"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.managers.name} to manage instance-family in compartment id ${var.compartment_id}",
  ]
}
