variable "project_id" {
  description = "ID del proyecto en Google Cloud"
  type        = string
}

variable "region" {
  description = "Región de la VM"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "Zona de la VM"
  type        = string
  default     = "us-east1-b"
}

variable "vm_name" {
  description = "Nombre de la instancia"
  type        = string
  default     = "budget-app"
}

variable "disk_size" {
  description = "Tamaño del disco en GB"
  type        = number
  default     = 20
}

variable "swap_size" {
  description = "Tamaño del swap en GB"
  type        = number
  default     = 1
}

variable "db_root_password" {
  description = "Contraseña root de MySQL"
  default     = "rootpass123"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  default     = "churchaccounting"
}

variable "db_user" {
  description = "Usuario MySQL"
  default     = "budget_user"
}

variable "db_password" {
  description = "Contraseña usuario MySQL"
  default     = "budgetpass123"
}

variable "git_repo" {
  description = "URL del repositorio Git"
  default     = "https://github.com/jvillalobosvega/churchaccounting.git"
}

variable "ssh_user" {
  description = "Usuario para SSH"
  default     = "jose"
}

variable "ssh_private_key_path" {
  description = "Ruta a la llave privada SSH"
  default     = "~/.ssh/google_compute_engine"
}