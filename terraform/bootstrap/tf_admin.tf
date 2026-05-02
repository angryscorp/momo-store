# Service account that the *infra* terraform step will use.
resource "yandex_iam_service_account" "tf_admin" {
  folder_id   = var.folder_id
  name        = "tf-admin"
  description = "Terraform admin SA to manage momo-store infrastructure"
}

resource "yandex_resourcemanager_folder_iam_member" "tf_admin_admin" {
  folder_id = var.folder_id
  role      = "admin"
  member    = "serviceAccount:${yandex_iam_service_account.tf_admin.id}"
}

# JSON (RSA) key to use by the yandex provider to call the YC API in the
# infra step (VPC, K8s, IAM). Output to disk via `terraform output`.
resource "yandex_iam_service_account_key" "tf_admin" {
  service_account_id = yandex_iam_service_account.tf_admin.id
  description        = "Key for terraform infra step"
  key_algorithm      = "RSA_2048"
}

# HMAC key (S3-compatible Object Storage uses AWS-style access/secret keys).
# The infra step's S3 backend (and the bucket creation below) need this.
resource "yandex_iam_service_account_static_access_key" "tf_admin" {
  service_account_id = yandex_iam_service_account.tf_admin.id
  description        = "Static key for Object Storage access"
}

# IAM grants take ~10–30s to propagate before the new SA can actually
# call the API. Without this sleep the bucket creation below sometimes
# races and fails with "AccessDenied".
resource "time_sleep" "wait_for_iam" {
  depends_on      = [yandex_resourcemanager_folder_iam_member.tf_admin_admin]
  create_duration = "30s"
}
