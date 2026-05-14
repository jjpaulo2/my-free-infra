output "instance_id" {
  description = "OCID da instância criada"
  value       = oci_core_instance.this.id
}

output "public_ip" {
  description = "IP público da instância"
  value       = oci_core_instance.this.public_ip
}

output "private_ip" {
  description = "IP privado da instância"
  value       = oci_core_instance.this.private_ip
}

output "ssh_private_key" {
  description = "Chave privada SSH para acesso à instância (PEM)"
  value       = tls_private_key.this.private_key_openssh
  sensitive   = true
}

output "ssh_public_key" {
  description = "Chave pública SSH da instância"
  value       = tls_private_key.this.public_key_openssh
}

output "nsg_id" {
  description = "OCID do Network Security Group da instância"
  value       = oci_core_network_security_group.this.id
}