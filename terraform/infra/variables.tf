variable "cloud_id" {
  type        = string
  description = "Yandex Cloud ID (yc config get cloud-id)"
}

variable "folder_id" {
  type        = string
  description = "Yandex Cloud folder ID (yc config get folder-id)"
}

variable "zone" {
  type        = string
  description = "Default availability zone for the cluster and node group"
  default     = "ru-central1-a"
}

variable "tf_admin_key_path" {
  type        = string
  description = "Path to the tf-admin SA JSON key produced by bootstrap"
  default     = "~/.config/momo-store/tf-admin-key.json"
}

variable "k8s_version" {
  type        = string
  description = "Managed Kubernetes version"
  default     = "1.33"
}

variable "node_group_size" {
  type        = number
  description = "Fixed number of worker nodes"
  default     = 2
}
