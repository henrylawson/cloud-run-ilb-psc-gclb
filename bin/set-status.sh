#!/bin/bash
set -euo pipefail

STATUS_CODE="${2}"
GCS_FILE="${1}"

echo "${STATUS_CODE}" > "./${GCS_FILE}"
gsutil cp "./${GCS_FILE}" "gs://cloud-run-status-files-423h/${GCS_FILE}"
rm "./${GCS_FILE}"