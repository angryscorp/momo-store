resource "yandex_kubernetes_node_group" "main" {
  cluster_id  = yandex_kubernetes_cluster.main.id
  name        = "momo-store-ng"
  description = "Preemptible node group, ${var.node_group_size} × standard-v3 (2 vCPU / 4 GB)"
  version     = var.k8s_version

  scale_policy {
    fixed_scale {
      size = var.node_group_size
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores         = 2
      memory        = 4
      core_fraction = 100
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

    # Preemptible: cheaper, but YC may evict the VM up to once a day.
    scheduling_policy {
      preemptible = true
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.a.id]
      # Public IPs on nodes so they can pull images and reach the internet without us provisioning a NAT gateway.
      nat = true
    }

    container_runtime {
      type = "containerd"
    }
  }
}
