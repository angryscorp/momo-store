# Auth: tf-admin SA's JSON key (created by bootstrap). Path is configurable
# so you can keep the key outside the repo (e.g. ~/.config/momo-store/).
provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
  service_account_key_file = pathexpand(var.tf_admin_key_path)
}
