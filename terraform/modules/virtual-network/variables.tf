variable "compartment_id" {
  description = "OCID do compartimento onde a VCN será criada"
  type        = string
}

variable "display_name" {
  description = "Nome de exibição da VCN"
  type        = string
}

variable "cidr_block" {
  description = "Bloco CIDR da VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "Bloco CIDR da subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "allow_public_ip" {
  description = "Indica se a subnet permite IP público (true) ou não (false)"
  type        = bool
  default     = false
}