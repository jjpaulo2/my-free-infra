output "vcn_id" {
  description = "OCID da VCN criada"
  value       = oci_core_vcn.this.id
}

output "subnet_id" {
  description = "OCID da subnet criada"
  value       = oci_core_subnet.this.id
}