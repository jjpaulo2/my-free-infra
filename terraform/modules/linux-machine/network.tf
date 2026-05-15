resource "oci_core_network_security_group" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.display_name
}

resource "oci_core_network_security_group_security_rule" "ingress_tcp" {
  count = length(var.ingress_tcp_rules)

  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.ingress_tcp_rules[count.index].cidr
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = var.ingress_tcp_rules[count.index].port
      max = var.ingress_tcp_rules[count.index].port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_udp" {
  count = length(var.ingress_udp_rules)

  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = var.ingress_udp_rules[count.index].cidr
  source_type               = "CIDR_BLOCK"

  udp_options {
    destination_port_range {
      min = var.ingress_udp_rules[count.index].port
      max = var.ingress_udp_rules[count.index].port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_icmp" {
  count = var.allow_icmp ? 1 : 0

  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "egress_all" {
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}