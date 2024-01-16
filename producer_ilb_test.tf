resource "google_compute_instance" "ilb_test" {
  project      = var.producer_project
  name         = "ilb-test-instance"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"

    access_config {
    }
  }

  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}