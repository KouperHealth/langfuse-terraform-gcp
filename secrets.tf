resource "google_secret_manager_secret" "ee_key" {
  secret_id = "${var.name}-ee-key"

  replication {
    auto {}
  }

  labels = {
    managed-by = "terraform"
    app        = "langfuse"
  }
}

resource "google_secret_manager_secret_version" "ee_key" {
  secret = google_secret_manager_secret.ee_key.id

  secret_data = "REPLACE_WITH_YOUR_ENCRYPTION_KEY"
}

resource "google_secret_manager_secret_iam_member" "ee_key_accessor" {
  secret_id = google_secret_manager_secret.ee_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.langfuse.email}"
}

resource "google_secret_manager_secret" "ee_license_key" {
  secret_id = "${var.name}-ee-license-key"

  replication {
    auto {}
  }

  labels = {
    managed-by = "terraform"
    app        = "langfuse"
  }
}

resource "google_secret_manager_secret_version" "ee_license_key" {
  secret      = google_secret_manager_secret.ee_license_key.id
  secret_data = "REPLACE_WITH_YOUR_EE_LICENSE_KEY"

  # Real value is pushed out-of-band via `gcloud secrets versions add` —
  # ignore it here so a later apply doesn't clobber it back to the placeholder.
  lifecycle {
    ignore_changes = [secret_data]
  }
}

# Reads whatever version is currently live in Secret Manager (placeholder or real key)
# so it can be synced into the Kubernetes secret below.
data "google_secret_manager_secret_version" "ee_license_key" {
  secret     = google_secret_manager_secret.ee_license_key.id
  depends_on = [google_secret_manager_secret_version.ee_license_key]
}
