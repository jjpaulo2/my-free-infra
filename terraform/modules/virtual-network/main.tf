resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  display_name   = var.display_name
  cidr_blocks    = [var.cidr_block]
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.display_name
  enabled        = true
}

resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  display_name   = var.display_name

  route_rules {
    network_entity_id = oci_core_internet_gateway.this.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "this" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.this.id
  display_name               = var.display_name
  cidr_block                 = var.subnet_cidr_block
  route_table_id             = oci_core_route_table.this.id
  prohibit_public_ip_on_vnic = !var.allow_public_ip
}
