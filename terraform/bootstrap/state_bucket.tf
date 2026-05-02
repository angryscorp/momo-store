# Bucket names in YC Object Storage are globally unique, so we suffix.
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "yandex_storage_bucket" "tf_state" {
  bucket = "momo-store-tfstate-${random_id.bucket_suffix.hex}"

  # Use the freshly-minted SA's HMAC keys, not the human user's.
  access_key = yandex_iam_service_account_static_access_key.tf_admin.access_key
  secret_key = yandex_iam_service_account_static_access_key.tf_admin.secret_key

  # Versioning lets us recover a previous state file if `apply` corrupts it.
  versioning {
    enabled = true
  }

  # Garbage-collect old state revisions: keep the last 90 days for recovery, drop anything older.
  lifecycle_rule {
    id      = "expire-noncurrent-state"
    enabled = true
    noncurrent_version_expiration {
      days = 90
    }
  }

  depends_on = [time_sleep.wait_for_iam]
}
