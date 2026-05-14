variable "compartment_id" {
  description = "OCID do compartimento onde a VM será criada"
  type        = string
}

variable "display_name" {
  description = "Nome de exibição da VM"
  type        = string
}

variable "shape" {
  description = "Shape da instância OCI"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "os" {
  description = "Sistema operacional da VM"
  type = object({
    name    = string
    version = string
  })
  default = {
    name    = "Canonical Ubuntu"
    version = "24.04 Minimal"
  }
}

variable "subnet_id" {
  description = "OCID da subnet onde a VM será criada"
  type        = string
}

variable "assign_public_ip" {
  description = "Indica se a VM deve receber um IP público"
  type        = bool
  default     = false
}

variable "boot_volume_size_in_gbs" {
  description = "Tamanho do volume de boot em GB"
  type        = number
  default     = 50
}

variable "vcn_id" {
  description = "OCID da VCN onde o NSG será criado"
  type        = string
}

variable "ingress_tcp_rules" {
  description = "Portas de entrada TCP liberadas no NSG"
  type = list(object({
    port = number
    cidr = string
  }))
  default = []
}

variable "ingress_udp_rules" {
  description = "Portas de entrada UDP liberadas no NSG"
  type = list(object({
    port = number
    cidr = string
  }))
  default = []
}

variable "allow_icmp" {
  description = "Indica se o tráfego ICMP deve ser permitido no NSG"
  type        = bool
  default     = false
}