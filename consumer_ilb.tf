resource "google_compute_subnetwork" "producer_ilb_proxy_subnet_syd" {
  provider      = google-beta
  project       = var.consumer_project
  name          = "ilb-proxy-subnet-syd"
  ip_cidr_range = "10.0.0.0/24"
  region        = "australia-southeast1"
  purpose       = "GLOBAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = "default"
}

resource "google_compute_address" "producer_ilb_syd" {
  project      = var.consumer_project
  name         = "ilb-address-syd"
  subnetwork   = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/regions/australia-southeast1/subnetworks/default"
  address_type = "INTERNAL"
  address      = "10.152.0.40"
  region       = google_compute_subnetwork.producer_ilb_proxy_subnet_syd.region
}

resource "google_compute_global_forwarding_rule" "producer_ilb_syd" {
  provider              = google-beta
  project               = var.consumer_project
  name                  = "hello-service-internal-syd"
  target                = google_compute_target_http_proxy.producer_ilb.id
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  depends_on            = [google_compute_subnetwork.producer_ilb_proxy_subnet_syd]
  ip_address            = google_compute_address.producer_ilb_syd.address
  network               = "default"
  subnetwork            = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/regions/australia-southeast1/subnetworks/default"
}

resource "google_compute_subnetwork" "producer_ilb_proxy_subnet_mel" {
  provider      = google-beta
  project       = var.consumer_project
  name          = "ilb-proxy-subnet-mel"
  ip_cidr_range = "10.1.0.0/24"
  region        = "australia-southeast2"
  purpose       = "GLOBAL_MANAGED_PROXY"
  role          = "ACTIVE"
  network       = "default"
}

resource "google_compute_address" "producer_ilb_mel" {
  project      = var.consumer_project
  name         = "ilb-address-mel"
  subnetwork   = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/regions/australia-southeast2/subnetworks/default"
  address_type = "INTERNAL"
  address      = "10.192.0.40"
  region       = google_compute_subnetwork.producer_ilb_proxy_subnet_mel.region
}

resource "google_compute_global_forwarding_rule" "producer_ilb_mel" {
  provider              = google-beta
  project               = var.consumer_project
  name                  = "hello-service-internal-mel"
  target                = google_compute_target_http_proxy.producer_ilb.id
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  depends_on            = [google_compute_subnetwork.producer_ilb_proxy_subnet_mel]
  ip_address            = google_compute_address.producer_ilb_mel.address
  network               = "default"
  subnetwork            = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/regions/australia-southeast2/subnetworks/default"
}

resource "google_compute_target_http_proxy" "producer_ilb" {
  provider = google-beta
  project  = var.consumer_project
  name     = "hello-service-internal"
  url_map  = google_compute_url_map.producer_ilb.id
}

resource "google_compute_url_map" "producer_ilb" {
  provider        = google-beta
  project         = var.consumer_project
  name            = "hello-service-internal"
  description     = "a description"
  default_service = google_compute_backend_service.producer_ilb.id
}

resource "google_compute_backend_service" "producer_ilb" {
  provider = google-beta
  project  = var.consumer_project
  name     = "hello-service-internal"

  protocol    = "HTTPS"
  port_name   = "https"
  timeout_sec = 30

  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.syd_psc.id
  }

  backend {
    group = google_compute_region_network_endpoint_group.mel_psc.id
  }
}