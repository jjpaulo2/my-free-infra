output "node_0_public_ip" {
  value = module.node_0.public_ip
}

output "node_0_private_ip" {
  value = module.node_0.private_ip
}

output "node_0_ssh_private_key" {
  value     = module.node_0.ssh_private_key
  sensitive = true
}

output "node_1_public_ip" {
  value = module.node_1.public_ip
}

output "node_1_private_ip" {
  value = module.node_1.private_ip
}

output "node_1_ssh_private_key" {
  value     = module.node_1.ssh_private_key
  sensitive = true
}

output "node_heavy_0_public_ip" {
  value = module.node_heavy_0.public_ip
}

output "node_heavy_0_private_ip" {
  value = module.node_heavy_0.private_ip
}

output "node_heavy_0_ssh_private_key" {
  value     = module.node_heavy_0.ssh_private_key
  sensitive = true
}