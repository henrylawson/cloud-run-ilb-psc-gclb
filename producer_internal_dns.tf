resource "google_dns_managed_zone" "producer_internal" {
  project    = var.producer_project
  name       = "hello-service"
  dns_name   = "hello-service.internal."
  depends_on = [google_project_service.dns]
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "https://www.googleapis.com/compute/v1/projects/${var.producer_project}/global/networks/default"
    }
  }
}

resource "google_dns_record_set" "producer_internal" {
  project      = var.producer_project
  name         = google_dns_managed_zone.producer_internal.dns_name
  managed_zone = google_dns_managed_zone.producer_internal.name
  type         = "A"
  ttl          = 300

  routing_policy {
    geo {
      location = "australia-southeast1"

      health_checked_targets {
        internal_load_balancers {
          load_balancer_type = "regionalL7ilb"
          ip_address         = google_compute_address.producer_ilb_syd.address
          port               = 443
          ip_protocol        = "tcp"
          network_url        = "https://www.googleapis.com/compute/v1/projects/${var.producer_project}/global/networks/default"
          project            = var.producer_project
          region             = "australia-southeast1"
        }
      }
    }

    geo {
      location = "australia-southeast2"

      health_checked_targets {
        internal_load_balancers {
          load_balancer_type = "regionalL7ilb"
          ip_address         = google_compute_address.producer_ilb_mel.address
          port               = 443
          ip_protocol        = "tcp"
          network_url        = "https://www.googleapis.com/compute/v1/projects/${var.producer_project}/global/networks/default"
          project            = var.producer_project
          region             = "australia-southeast2"
        }
      }
    }
  }
}