resource "yandex_vpc_network" "main" {
  name        = "momo-store-net"
  description = "Network for Momo Store K8s cluster"
}

resource "yandex_vpc_subnet" "a" {
  name           = "momo-store-subnet-a"
  description    = "Single subnet in ru-central1-a – zonal cluster, single AZ"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.10.0.0/24"]
}
