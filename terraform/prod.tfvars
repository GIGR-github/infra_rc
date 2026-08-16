environment    = "prod"
manager_count  = 1   # 3 ноды обеспечивают кворум Raft для Docker Swarm
worker_count   = 2   # 3 воркера для балансировки нагрузки
manager_memory = "2G"
worker_memory  = "2G"
manager_cpus   = 2
worker_cpus    = 2
