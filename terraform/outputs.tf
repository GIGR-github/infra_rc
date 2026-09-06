output "swarm_manager_ip" {
  value = multipass_instance.manager[0].ipv4[0]
  description = "IP address of the Swarm Manager node"
}
