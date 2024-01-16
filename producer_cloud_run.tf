resource "google_cloud_run_v2_service" "au_syd" {
  project  = var.producer_project
  name     = "hello-au-syd"
  location = "australia-southeast1"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  depends_on = [google_project_service.run, google_project_service.compute, google_project_iam_member.run_user]
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
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }

  depends_on = [google_project_service.run, google_project_service.compute, google_project_iam_member.run_user]
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