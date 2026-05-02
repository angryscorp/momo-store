# Auth: this step runs as the human user, using a short-lived IAM token.
provider "yandex" {
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}
