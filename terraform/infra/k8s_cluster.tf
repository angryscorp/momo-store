resource "yandex_kubernetes_cluster" "main" {
  name        = "momo-store-k8s"
  description = "Momo Store cluster (zonal, single AZ – learning project)"

  network_id = yandex_vpc_network.main.id

  master {
    version = var.k8s_version

    # Zonal master = single control plane in one AZ. Cheaper than regional.
    zonal {
      zone      = yandex_vpc_subnet.a.zone
      subnet_id = yandex_vpc_subnet.a.id
    }

    # Public IP on the master so we can `kubectl` from outside.
    public_ip = true
  }

  service_account_id      = yandex_iam_service_account.k8s_cluster.id
  node_service_account_id = yandex_iam_service_account.k8s_nodes.id

  # REGULAR = stable releases with periodic upgrades.
  release_channel = "REGULAR"

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s_cluster_agent,
    yandex_resourcemanager_folder_iam_member.k8s_cluster_lb,
    yandex_resourcemanager_folder_iam_member.k8s_nodes_puller,
  ]
}
