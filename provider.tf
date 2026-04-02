provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  host                   = try("https://${google_container_cluster.this.endpoint}", "")
  cluster_ca_certificate = try(base64decode(google_container_cluster.this.master_auth[0].cluster_ca_certificate), "")
  token                  = try(data.google_client_config.current.access_token, "")
}

provider "helm" {
  kubernetes {
    host                   = try("https://${google_container_cluster.this.endpoint}", "")
    cluster_ca_certificate = try(base64decode(google_container_cluster.this.master_auth[0].cluster_ca_certificate), "")
    token                  = try(data.google_client_config.current.access_token, "")
  }
}
