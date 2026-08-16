variable "environment" {
  type        = string
  description = "Название контура (staging или prod)"
}

variable "manager_count" {
  type        = number
  description = "Количество Manager-нод в Swarm"
}

variable "worker_count" {
  type        = number
  description = "Количество Worker-нод в Swarm"
}

variable "manager_memory" {
  type        = string
  description = "Объем RAM для Manager-ноды (например: 2G, 4G)"
}

variable "worker_memory" {
  type        = string
  description = "Объем RAM для Worker-ноды"
}

variable "manager_cpus" {
  type        = number
  description = "Количество vCPU для Manager-ноды"
}

variable "worker_cpus" {
  type        = number
  description = "Количество vCPU для Worker-ноды"
}
variable "ssh_public_key" {
  type        = string
  description = "Public SSH key content for cloud-init"
}