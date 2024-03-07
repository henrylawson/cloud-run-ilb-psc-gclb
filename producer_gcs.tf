resource "google_storage_bucket" "status" {
  project                     = var.producer_project
  name                        = "cloud-run-status-files-423h"
  location                    = "australia-southeast1"
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
}