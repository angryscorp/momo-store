output "tf_state_bucket" {
  description = "Bucket name for the infra step's terraform state. Goes into terraform/infra/backend.hcl."
  value       = yandex_storage_bucket.tf_state.bucket
}

output "tf_admin_access_key" {
  description = "HMAC access key for the s3 backend (export as AWS_ACCESS_KEY_ID)."
  value       = yandex_iam_service_account_static_access_key.tf_admin.access_key
  sensitive   = true
}

output "tf_admin_secret_key" {
  description = "HMAC secret key for the s3 backend (export as AWS_SECRET_ACCESS_KEY)."
  value       = yandex_iam_service_account_static_access_key.tf_admin.secret_key
  sensitive   = true
}

# The infra step authenticates to the YC API using this JSON key.
# Save it to disk: `terraform output -raw tf_admin_key_json > ~/.config/momo-store/tf-admin-key.json`
output "tf_admin_key_json" {
  description = "JSON key for tf-admin SA; save it to tf_admin_key_path for the infra provider."
  sensitive   = true
  value = jsonencode({
    id                 = yandex_iam_service_account_key.tf_admin.id
    service_account_id = yandex_iam_service_account.tf_admin.id
    created_at         = yandex_iam_service_account_key.tf_admin.created_at
    key_algorithm      = yandex_iam_service_account_key.tf_admin.key_algorithm
    public_key         = yandex_iam_service_account_key.tf_admin.public_key
    private_key        = yandex_iam_service_account_key.tf_admin.private_key
  })
}
