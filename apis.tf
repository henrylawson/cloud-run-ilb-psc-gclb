resource "google_project_service" "run" {
  project                    = var.producer_project
  service                    = "run.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service" "vpcaccess" {
  project                    = var.producer_project
  service                    = "vpcaccess.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_service_identity" "run" {
  provider = google-beta

  project = google_project_service.run.project
  service = google_project_service.run.service
}

resource "google_project_iam_member" "run_user" {
  project = var.producer_project
  role    = "roles/run.serviceAgent"
  member  = "serviceAccount:${google_project_service_identity.run.email}"
}

resource "google_project_service" "compute" {
  project = var.producer_project
  service = "compute.googleapis.com"
}

resource "google_project_service_identity" "compute" {
  provider = google-beta

  project = google_project_service.compute.project
  service = google_project_service.compute.service
}

resource "google_project_service" "compute_consumer" {
  project = var.consumer_project
  service = "compute.googleapis.com"
}

resource "google_project_service_identity" "compute_consumer" {
  provider = google-beta

  project = google_project_service.compute_consumer.project
  service = google_project_service.compute_consumer.service
}

resource "google_project_service" "dns" {
  project = var.producer_project
  service = "dns.googleapis.com"
}

resource "google_project_service" "dns_consumer" {
  project = var.consumer_project
  service = "dns.googleapis.com"
}

resource "google_project_service" "compute_network" {
  project = var.network_project
  service = "compute.googleapis.com"
}

resource "google_project_service" "dns_network" {
  project = var.network_project
  service = "dns.googleapis.com"
}