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
