output "cluster_name" {
  description = "GKE Cluster Name to use for a Kubernetes terraform provider"
  value       = google_container_cluster.this.name
}

output "cluster_host" {
  description = "GKE Cluster host to use for a Kubernetes terraform provider"
  value       = "https://${google_container_cluster.this.endpoint}"
}

output "cluster_ca_certificate" {
  description = "GKE Cluster CA certificate to use for a Kubernetes terraform provider"
  value       = base64decode(google_container_cluster.this.master_auth[0].cluster_ca_certificate)
  sensitive   = true
}

output "cluster_token" {
  description = "GKE Cluster Token to use for a Kubernetes terraform provider"
  value       = data.google_client_config.current.access_token
  sensitive   = true
}

output "ee_key_secret_name" {
  description = "Name of the GCP Secret Manager secret containing the enterprise encryption key"
  value       = google_secret_manager_secret.ee_key.secret_id
}

output "ingress_ip" {
  description = "Static IP address for the ingress load balancer - configure your DNS A record to point to this IP"
  value       = google_compute_global_address.ingress.address
}
