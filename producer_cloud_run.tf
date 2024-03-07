resource "google_cloud_run_v2_service" "au_syd" {
  project  = var.producer_project
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
  project       = var.producer_project
  name          = "syd"
  region        = "australia-southeast1"
  ip_cidr_range = "10.9.0.0/28"
  network       = "default"
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
  project  = var.producer_project
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

resource "google_vpc_access_connector" "au_mel_connector" {
  project       = var.producer_project
  name          = "mel"
  region        = "australia-southeast2"
  ip_cidr_range = "10.8.0.0/28"
  network       = "default"
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