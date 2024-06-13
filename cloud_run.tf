resource "google_cloud_run_v2_service" "au_syd" {
  project  = var.apps_project
  name     = "hello-au-syd"
  location = "australia-southeast1"

  template {
    timeout = "3600s"

    scaling {
      max_instance_count = 1
    }

    containers {
      image = "australia-southeast1-docker.pkg.dev/hgl-env-a/containers/cloud-run-fun@${var.container_tag}"

      resources {
        limits = {
          cpu    = "4"
          memory = "16Gi"
        }
      }

      env {
        name  = "GCS_STATUS_BUCKET"
        value = google_storage_bucket.status.name
      }

      startup_probe {
        failure_threshold     = 5
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 3

        http_get {
          path = "/gcs-status?file=hello-au-syd-ready"
        }
      }

      liveness_probe {
        failure_threshold     = 5
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 3

        http_get {
          path = "/gcs-status?file=hello-au-syd-health"
        }
      }
    }

    vpc_access {
      connector = google_vpc_access_connector.au_syd_connector.id
      egress    = "ALL_TRAFFIC"
    }
  }

  depends_on = [google_project_service.run, google_project_service.vpcaccess, google_project_service.compute, google_project_iam_member.run_user]
}

resource "google_vpc_access_connector" "au_syd_connector" {
  project       = var.apps_project
  name          = "syd"
  region        = "australia-southeast1"
  ip_cidr_range = "10.9.0.0/28"
  network       = "https://www.googleapis.com/compute/v1/projects/${var.network_project}/global/networks/default"
  max_instances = 3
  min_instances = 2
  machine_type  = "e2-standard-4"

  depends_on = [google_project_service.vpcaccess]
}

data "google_iam_policy" "no_auth_syd" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "no_auth_syd" {
  location = google_cloud_run_v2_service.au_syd.location
  project  = google_cloud_run_v2_service.au_syd.project
  service  = google_cloud_run_v2_service.au_syd.name

  policy_data = data.google_iam_policy.no_auth_syd.policy_data
}

resource "google_cloud_run_v2_service" "au_mel" {
  project  = var.apps_project
  name     = "hello-au-mel"
  location = "australia-southeast2"

  template {
    timeout = "3600s"

    scaling {
      max_instance_count = 1
    }

    containers {
      image = "australia-southeast1-docker.pkg.dev/hgl-env-a/containers/cloud-run-fun@${var.container_tag}"

      resources {
        limits = {
          cpu    = "4"
          memory = "16Gi"
        }
      }

      env {
        name  = "GCS_STATUS_BUCKET"
        value = google_storage_bucket.status.name
      }

      startup_probe {
        failure_threshold     = 5
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 3

        http_get {
          path = "/gcs-status?file=hello-au-mel-ready"
        }
      }

      liveness_probe {
        failure_threshold     = 5
        initial_delay_seconds = 10
        timeout_seconds       = 3
        period_seconds        = 3

        http_get {
          path = "/gcs-status?file=hello-au-mel-health"
        }
      }
    }

    vpc_access {
      connector = google_vpc_access_connector.au_mel_connector.id
      egress    = "ALL_TRAFFIC"
    }
  }

  depends_on = [google_project_service.run, google_project_service.vpcaccess, google_project_service.compute, google_project_iam_member.run_user]
}

resource "google_compute_region_network_endpoint_group" "syd" {
  project               = var.apps_project
  name                  = "hello-au-syd"
  network_endpoint_type = "SERVERLESS"
  region                = "australia-southeast1"
  depends_on            = [google_project_service.compute]

  cloud_run {
    service = google_cloud_run_v2_service.au_syd.name
  }
}

resource "google_compute_region_backend_service" "ilb_syd" {
  provider = google-beta
  project  = var.apps_project
  name     = "hello-service-internal-syd"
  region   = "australia-southeast1"

  protocol    = "HTTPS"
  timeout_sec = 30

  load_balancing_scheme = "INTERNAL_MANAGED"
  depends_on            = [google_project_service.compute]

  backend {
    group           = google_compute_region_network_endpoint_group.syd.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_vpc_access_connector" "au_mel_connector" {
  project       = var.apps_project
  name          = "mel"
  region        = "australia-southeast2"
  ip_cidr_range = "10.8.0.0/28"
  network       = "https://www.googleapis.com/compute/v1/projects/${var.network_project}/global/networks/default"
  max_instances = 3
  min_instances = 2
  machine_type  = "e2-standard-4"

  depends_on = [google_project_service.vpcaccess]
}

data "google_iam_policy" "no_auth_mel" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "no_auth_mel" {
  location = google_cloud_run_v2_service.au_mel.location
  project  = google_cloud_run_v2_service.au_mel.project
  service  = google_cloud_run_v2_service.au_mel.name

  policy_data = data.google_iam_policy.no_auth_mel.policy_data
}

resource "google_compute_region_network_endpoint_group" "mel" {
  project               = var.apps_project
  name                  = "hello-au-mel"
  network_endpoint_type = "SERVERLESS"
  region                = "australia-southeast2"
  depends_on            = [google_project_service.compute]

  cloud_run {
    service = google_cloud_run_v2_service.au_mel.name
  }
}

resource "google_compute_region_backend_service" "ilb_mel" {
  provider = google-beta
  project  = var.apps_project
  name     = "hello-service-internal-mel"
  region   = "australia-southeast2"

  protocol    = "HTTPS"
  timeout_sec = 30
  depends_on  = [google_project_service.compute]

  load_balancing_scheme = "INTERNAL_MANAGED"

  backend {
    group           = google_compute_region_network_endpoint_group.mel.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}