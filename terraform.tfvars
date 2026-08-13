# GCP Project Configuration
project_id = "ringed-cell-357023"
region     = "us-central1"

# Langfuse Configuration
domain = "langfuse.kouperhealth.com"
name   = "primus-langfuse"

# Kubernetes Configuration
kubernetes_namespace = "primus-langfuse"
subnetwork_cidr      = "10.0.0.0/16"

# Database Configuration
database_instance_tier              = "db-perf-optimized-N-2"
database_instance_availability_type = "REGIONAL"
database_instance_edition           = "ENTERPRISE_PLUS"

# Cache Configuration
cache_tier           = "STANDARD_HA"
cache_memory_size_gb = 1

# Langfuse Helm Chart
langfuse_chart_version = "1.5.14"

# EE license key — value is sourced from GCP Secret Manager (see secrets.tf /
# ee_license_key_secret_name output), not stored here. Push the real key with:
#   gcloud secrets versions add <ee_license_key_secret_name> --data-file=-
additional_env = [
  {
    name = "LANGFUSE_EE_LICENSE_KEY"
    valueFrom = {
      secretKeyRef = {
        name = "langfuse"
        key  = "ee-license-key"
      }
    }
  }
]

# GKE Control Plane Access — add your public IP(s) here (run: gcloud compute addresses list or curl -s ifconfig.me)
master_authorized_networks = [
  # Jamf Trust VPN egress IPs — US West
  { cidr_block = "52.35.167.128/32", display_name = "jamf-us-west-1" },
  { cidr_block = "54.68.255.75/32",  display_name = "jamf-us-west-2" },
  { cidr_block = "54.186.76.74/32",  display_name = "jamf-us-west-3" },
  # Jamf Trust VPN egress IPs — US East
  { cidr_block = "54.209.62.128/32", display_name = "jamf-us-east-1" },
  { cidr_block = "52.200.243.25/32", display_name = "jamf-us-east-2" },
  { cidr_block = "54.165.60.253/32", display_name = "jamf-us-east-3" },
  # Individual IPs (Jamf Trust is split-tunnel — add each developer's ISP IP as needed)
  # { cidr_block = "136.56.29.170/32", display_name = "andrew" },
]
