resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

data "oci_core_images" "this" {
  compartment_id           = var.compartment_id
  operating_system         = var.os.name
  operating_system_version = var.os.version
  shape                    = var.shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
  state                    = "AVAILABLE"
}

resource "oci_core_instance" "this" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = var.display_name
  shape               = var.shape

  metadata = {
    ssh_authorized_keys = tls_private_key.this.public_key_openssh
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.this.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
    display_name     = var.display_name
    nsg_ids          = [oci_core_network_security_group.this.id]
  }

  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}