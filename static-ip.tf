# Static IP address for the ingress load balancer
# This IP will persist across deployments and won't change
resource "google_compute_global_address" "ingress" {
  name = "${var.name}-ingress"
}
