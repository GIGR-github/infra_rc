terraform {
  required_providers {
    multipass = {
      source  = "todoroff/multipass"
      version = "~> 1.7.0"
    }
	local = {
        source  = "hashicorp/local"
        version = "~> 2.4"
    }
  }
}

provider "multipass" {}

resource "multipass_instance" "manager" {
  count  = var.manager_count
  name   = "node-manager-${var.environment}-${count.index + 1}"
  cpus   = var.manager_cpus
  memory = var.manager_memory
  cloud_init = templatefile("${path.module}/init.yml.tftpl", {
    ssh_public_key = var.ssh_public_key
  })
}

# Создаем N Worker-нод
resource "multipass_instance" "worker" {
  count  = var.worker_count
  name   = "node-worker-${var.environment}-${count.index + 1}"
  cpus   = var.worker_cpus
  memory = var.worker_memory
  cloud_init = templatefile("${path.module}/init.yml.tftpl", {
    ssh_public_key = var.ssh_public_key
  })
  depends_on = [ multipass_instance.manager ]
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inv.tpl", {
    managers = multipass_instance.manager
    workers  = multipass_instance.worker
  })
  filename = "${path.module}/inventory/nodes.ini"
}
