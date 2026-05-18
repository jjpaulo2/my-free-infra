output "vcn_id" {
  description = "OCID da VCN criada"
  value       = oci_core_vcn.this.id
}

output "subnet_id" {
  description = "OCID da subnet criada"
  value       = oci_core_subnet.this.id
}

output "vcn_cidr" {
  description = "CIDR da VCN criada"
  value       = oci_core_vcn.this.cidr_block
}

output "subnet_cidr" {
  description = "CIDR da subnet criada"
  value       = oci_core_subnet.this.cidr_block
}