resource "tls_private_key" "ilb" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ilb" {
  private_key_pem = tls_private_key.ilb.private_key_pem

  validity_period_hours = 87600

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["hello-service.internal"]

  subject {
    common_name  = "hello-service.internal"
    organization = "Hello Service, Internal"
  }
}

resource "google_compute_subnetwork" "ilb_proxy_subnet_syd" {
  provider      = google-beta
  project       = var.producer_project
  name          = "ilb-proxy-subnet-syd"
  ip_cidr_range = "10.0.0.0/24"
  region        = "australia-southeast1"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = "default"
  depends_on    = [google_project_service.compute]
}

resource "google_compute_address" "ilb_syd" {
  project      = var.producer_project
  name         = "ilb-address-syd"
  subnetwork   = "https://www.googleapis.com/compute/v1/projects/${var.producer_project}/regions/australia-southeast1/subnetworks/default"
  address_type = "INTERNAL"
  address      = "10.152.0.40"
  region       = google_compute_subnetwork.ilb_proxy_subnet_syd.region
  depends_on   = [google_project_service.compute]
}

resource "google_compute_forwarding_rule" "ilb_syd" {
  provider              = google-beta
  project               = var.producer_project
  name                  = "hello-service-internal-syd"
  target                = google_compute_region_target_https_proxy.ilb_syd.id
  port_range            = "443"
  load_balancing_scheme = "INTERNAL_MANAGED"
  depends_on            = [google_compute_subnetwork.ilb_proxy_subnet_syd, google_project_service.compute]
  ip_address            = google_compute_address.ilb_syd.address
  network               = "default"
  subnetwork            = "https://www.googleapis.com/compute/v1/projects/${var.producer_project}/regions/australia-southeast1/subnetworks/default"
  region                = "australia-southeast1"
  allow_global_access   = true
}

resource "google_compute_region_ssl_certificate" "ilb_syd" {
  project     = var.producer_project
  name_prefix = "ilb-syd"
  private_key = tls_private_key.ilb.private_key_pem
  certificate = tls_self_signed_cert.ilb.cert_pem
  region      = "australia-southeast1"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_target_https_proxy" "ilb_syd" {
  provider         = google-beta
  project          = var.producer_project
  name             = "hello-service-internal-syd"
  url_map          = google_compute_region_url_map.ilb_syd.id
  region           = "australia-southeast1"
  depends_on       = [google_project_service.compute]
  ssl_certificates = [google_compute_region_ssl_certificate.ilb_syd.self_link]
}

resource "google_compute_region_url_map" "ilb_syd" {
  provider        = google-beta
  project         = var.producer_project
  name            = "hello-service-internal-syd"
  description     = "a description"
  default_service = google_compute_region_backend_service.ilb_syd.id
  region          = "australia-southeast1"
  depends_on      = [google_project_service.compute]
}

resource "google_compute_region_backend_service" "ilb_syd" {
  provider = google-beta
  project  = var.producer_project
  name     = "hello-service-internal-syd"
  region   = "australia-southeast1"

  protocol    = "HTTPS"
  timeout_sec = 30

  load_balancing_scheme = "INTERNAL_MANAGED"
  depends_on            = [google_project_service.compute]

  backend {
    group           = google_compute_region_network_endpoint_group.syd.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_region_network_endpoint_group" "syd" {
  project               = var.producer_project
  name                  = "hello-au-syd"
  network_endpoint_type = "SERVERLESS"
  region                = "australia-southeast1"
  depends_on            = [google_project_service.compute]

  cloud_run {
    service = google_cloud_run_v2_service.au_syd.name
  }
}

resource "google_compute_subnetwork" "ilb_proxy_subnet_mel" {
  provider      = google-beta
  project       = var.producer_project
  name          = "ilb-proxy-subnet-mel"
  ip_cidr_range = "10.1.0.0/24"
  region        = "australia-southeast2"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = "default"
  depends_on    = [google_project_service.compute]
}

resource "google_compute_address" "ilb_mel" {
  project      = var.producer_project
  name         = "ilb-address-mel"
  subnetwork   = "https://www.googleapis.com/compute/v1/projects/${var.producer_project}/regions/australia-southeast2/subnetworks/default"
  address_type = "INTERNAL"
  address      = "10.192.0.40"
  region       = google_compute_subnetwork.ilb_proxy_subnet_mel.region
  depends_on   = [google_project_service.compute]
}

resource "google_compute_forwarding_rule" "ilb_mel" {
  project               = var.producer_project
  name                  = "hello-service-internal-mel"
  target                = google_compute_region_target_https_proxy.ilb_mel.id
  port_range            = "443"
  load_balancing_scheme = "INTERNAL_MANAGED"
  depends_on            = [google_compute_subnetwork.ilb_proxy_subnet_mel, google_project_service.compute]
  ip_address            = google_compute_address.ilb_mel.address
  network               = "default"
  subnetwork            = "https://www.googleapis.com/compute/v1/projects/${var.producer_project}/regions/australia-southeast2/subnetworks/default"
  region                = "australia-southeast2"
  allow_global_access   = true
}

resource "google_compute_region_ssl_certificate" "ilb_mel" {
  project     = var.producer_project
  name_prefix = "ilb-syd"
  private_key = tls_private_key.ilb.private_key_pem
  certificate = tls_self_signed_cert.ilb.cert_pem
  region      = "australia-southeast2"

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_target_https_proxy" "ilb_mel" {
  provider         = google-beta
  project          = var.producer_project
  name             = "hello-service-internal-mel"
  url_map          = google_compute_region_url_map.ilb_mel.id
  region           = "australia-southeast2"
  depends_on       = [google_project_service.compute]
  ssl_certificates = [google_compute_region_ssl_certificate.ilb_mel.self_link]
}

resource "google_compute_region_url_map" "ilb_mel" {
  provider        = google-beta
  project         = var.producer_project
  name            = "hello-service-internal-mel"
  description     = "a description"
  default_service = google_compute_region_backend_service.ilb_mel.id
  region          = "australia-southeast2"
  depends_on      = [google_project_service.compute]
}

resource "google_compute_region_backend_service" "ilb_mel" {
  provider = google-beta
  project  = var.producer_project
  name     = "hello-service-internal-mel"
  region   = "australia-southeast2"

  protocol    = "HTTPS"
  timeout_sec = 30
  depends_on  = [google_project_service.compute]

  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group           = google_compute_region_network_endpoint_group.mel.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_region_network_endpoint_group" "mel" {
  project               = var.producer_project
  name                  = "hello-au-mel"
  network_endpoint_type = "SERVERLESS"
  region                = "australia-southeast2"
  depends_on            = [google_project_service.compute]

  cloud_run {
    service = google_cloud_run_v2_service.au_mel.name
  }
}