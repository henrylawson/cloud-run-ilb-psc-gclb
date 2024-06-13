resource "google_compute_global_address" "gclb" {
  provider   = google-beta
  project    = var.ingress_project
  name       = "hello-service-public"
  depends_on = [google_project_service.compute_consumer]
}

resource "google_compute_global_forwarding_rule" "gclb" {
  project               = var.ingress_project
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
  project  = var.ingress_project
  name     = "hello-service-public"
  provider = google-beta
  url_map  = google_compute_url_map.gclb.id
  depends_on = [
    google_project_service.compute_consumer
  ]
}

resource "google_compute_url_map" "gclb" {
  project         = var.ingress_project
  name            = "hello-service-public"
  provider        = google-beta
  default_service = google_compute_backend_service.gclb.id
  depends_on      = [google_project_service.compute_consumer]
}

resource "google_compute_backend_service" "gclb" {
  project = var.ingress_project
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