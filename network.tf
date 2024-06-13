resource "google_compute_shared_vpc_host_project" "host" {
  project = var.network_project

  depends_on = [google_project_service.compute_network]
}

resource "google_compute_shared_vpc_service_project" "service1" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.apps_project
}

resource "google_compute_shared_vpc_service_project" "service2" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.ingress_project
}