resource "google_compute_global_address" "gclb" {
  provider   = google-beta
  project    = var.consumer_project
  name       = "hello-service-public"
  depends_on = [google_project_service.compute_consumer]
}

resource "google_compute_global_forwarding_rule" "gclb" {
  project               = var.consumer_project
  name                  = "hello-service-public"
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.gclb.id
  ip_address            = google_compute_global_address.gclb.id
  depends_on            = [google_project_service.compute_consumer]
}

resource "google_compute_target_http_proxy" "gclb" {
  project  = var.consumer_project
  name     = "hello-service-public"
  provider = google-beta
  url_map  = google_compute_url_map.gclb.id
  depends_on = [
    google_project_service.compute_consumer
  ]
}

resource "google_compute_url_map" "gclb" {
  project         = var.consumer_project
  name            = "hello-service-public"
  provider        = google-beta
  default_service = google_compute_backend_service.gclb.id
  depends_on      = [google_project_service.compute_consumer]
}

resource "google_compute_backend_service" "gclb" {
  project = var.consumer_project
  name    = "hello-service-public"

  load_balancing_scheme = "EXTERNAL_MANAGED"

  protocol    = "HTTPS"
  port_name   = "https"
  timeout_sec = 30
  depends_on  = [google_project_service.compute_consumer]

  backend {
    group = google_compute_region_network_endpoint_group.syd_psc.id
  }

  backend {
    group = google_compute_region_network_endpoint_group.mel_psc.id
  }
}

resource "google_compute_region_network_endpoint_group" "syd_psc" {
  project               = var.consumer_project
  name                  = "hello-au-syd"
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  region                = "australia-southeast1"
  depends_on            = [google_project_service.compute_consumer]
  psc_target_service    = google_compute_service_attachment.syd.id
  network               = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/global/networks/default"
  subnetwork            = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/regions/australia-southeast1/subnetworks/default"
}

resource "google_compute_region_network_endpoint_group" "mel_psc" {
  project               = var.consumer_project
  name                  = "hello-au-mel"
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  region                = "australia-southeast2"
  depends_on            = [google_project_service.compute_consumer]
  psc_target_service    = google_compute_service_attachment.mel.id
  network               = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/global/networks/default"
  subnetwork            = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/regions/australia-southeast2/subnetworks/default"
}