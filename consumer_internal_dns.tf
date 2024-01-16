resource "google_dns_managed_zone" "internal" {
  project    = var.consumer_project
  name       = "hello-service"
  dns_name   = "hello-service.internal."
  depends_on = [google_project_service.dns_consumer]
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/global/networks/default"
    }
  }
}

resource "google_dns_record_set" "internal" {
  project      = var.consumer_project
  name         = google_dns_managed_zone.internal.dns_name
  managed_zone = google_dns_managed_zone.internal.name
  type         = "A"
  ttl          = 300

  routing_policy {
    geo {
      location = "australia-southeast1"

      health_checked_targets {
        internal_load_balancers {
          load_balancer_type = "globalL7ilb"
          ip_address         = google_compute_address.producer_ilb_syd.address
          port               = 80
          ip_protocol        = "tcp"
          network_url        = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/global/networks/default"
          project            = var.consumer_project
        }
      }
    }

    geo {
      location = "australia-southeast2"

      health_checked_targets {
        internal_load_balancers {
          load_balancer_type = "globalL7ilb"
          ip_address         = google_compute_address.producer_ilb_mel.address
          port               = 80
          ip_protocol        = "tcp"
          network_url        = "https://www.googleapis.com/compute/v1/projects/${var.consumer_project}/global/networks/default"
          project            = var.consumer_project
        }
      }
    }
  }
}