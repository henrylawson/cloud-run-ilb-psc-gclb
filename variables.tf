variable "producer_project" {
  type    = string
  default = "hgl-env-cloud-run-psc1"
}

variable "consumer_project" {
  type    = string
  default = "hgl-env-cloud-run-psc2"
}

variable "network_project" {
  type    = string
  default = "hgl-env-cloud-run-psc3"
}

variable "container_tag" {
  type    = string
  default = "sha256:24ad69717f1f780b8bb4e74da020e22e5a7ce50d0e8dc4d72bb2d4fdc02527ce"
}