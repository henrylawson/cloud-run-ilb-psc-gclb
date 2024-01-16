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