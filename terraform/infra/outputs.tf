output "cluster_id" {
  value = yandex_kubernetes_cluster.main.id
}

output "cluster_name" {
  value = yandex_kubernetes_cluster.main.name
}

output "cluster_external_endpoint" {
  description = "Public Kubernetes API endpoint"
  value       = yandex_kubernetes_cluster.main.master[0].external_v4_endpoint
}

output "kubeconfig_command" {
  description = "Run this to merge the cluster into ~/.kube/config"
  value       = "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.main.id} --external --force"
}
