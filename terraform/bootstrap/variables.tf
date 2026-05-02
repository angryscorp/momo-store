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
  description = "Default availability zone"
  default     = "ru-central1-a"
}
