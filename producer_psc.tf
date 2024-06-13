resource "google_compute_subnetwork" "psc_syd" {
  provider      = google-beta
  project       = var.network_project
  name          = "psc-syd"
  ip_cidr_range = "10.2.0.0/24"
  region        = "australia-southeast1"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  role          = "ACTIVE"
  network       = "https://www.googleapis.com/compute/v1/projects/${var.network_project}/global/networks/default"
  depends_on    = [google_project_service.compute]
}

resource "google_compute_service_attachment" "syd" {
  project = var.producer_project
  name    = "hello-syd"
  region  = "australia-southeast1"

  enable_proxy_protocol = false
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = [google_compute_subnetwork.psc_syd.id]
  target_service        = google_compute_forwarding_rule.ilb_syd.id
}

resource "google_compute_subnetwork" "psc_mel" {
  provider      = google-beta
  project       = var.network_project
  name          = "psc-mel"
  ip_cidr_range = "10.3.0.0/24"
  region        = "australia-southeast2"
  purpose       = "PRIVATE_SERVICE_CONNECT"
  role          = "ACTIVE"
  network       = "https://www.googleapis.com/compute/v1/projects/${var.network_project}/global/networks/default"
  depends_on    = [google_project_service.compute]
}

resource "google_compute_service_attachment" "mel" {
  project = var.producer_project
  name    = "hello-mel"
  region  = "australia-southeast2"

  enable_proxy_protocol = false
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = [google_compute_subnetwork.psc_mel.id]
  target_service        = google_compute_forwarding_rule.ilb_mel.id
}