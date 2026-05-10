# SA the K8s master uses to manage cloud resources.
resource "yandex_iam_service_account" "k8s_cluster" {
  folder_id   = var.folder_id
  name        = "k8s-cluster"
  description = "SA for momo-store K8s master"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_cluster_agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_cluster_lb" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

# Required for Service type=LoadBalancer to create a Yandex Network Load Balancer.
resource "yandex_resourcemanager_folder_iam_member" "k8s_cluster_load_balancer_admin" {
  folder_id = var.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

# SA assigned to worker nodes (only needs to pull container images from YCR).
resource "yandex_iam_service_account" "k8s_nodes" {
  folder_id   = var.folder_id
  name        = "k8s-nodes"
  description = "SA for momo-store K8s worker nodes (image pull)"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_nodes_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}
