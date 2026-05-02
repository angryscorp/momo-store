# State lives in the S3 bucket created by terraform/bootstrap.
terraform {
  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    region = "ru-central1-a"
    key    = "infra/terraform.tfstate"

    # YC Object Storage is S3-compatible but isn't AWS, so we have to disable AWS-specific checks.
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
}
