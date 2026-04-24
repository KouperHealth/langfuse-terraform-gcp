# Langfuse GCP Deployment Guide

This guide walks you through deploying Langfuse on Google Cloud Platform using Terraform.

## Prerequisites

- Terraform >= 1.0
- Google Cloud SDK (`gcloud`) installed and authenticated
- A GCP project with billing enabled
- Required GCP APIs enabled:
  - Compute Engine API
  - Kubernetes Engine API
  - Cloud SQL Admin API
  - Cloud Storage API
  - Secret Manager API
  - Redis API

## Configuration

1. **Copy the example configuration file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your values:**
   - `project_id`: Your GCP project ID
   - `region`: GCP region (default: us-central1)
   - `domain`: Your domain name (e.g., langfuse.kouperhealth.com)
   - `name`: Installation name (e.g., primus-langfuse)
   - `kubernetes_namespace`: Kubernetes namespace name
   - Other optional configuration values

3. **Update the enterprise encryption key placeholder:**
   
   Edit `secrets.tf` and replace `"REPLACE_WITH_YOUR_ENCRYPTION_KEY"` with your actual enterprise license key or encryption key value.

## Deployment Steps

### Step 1: Initialize Terraform

```bash
terraform init
```

### Step 2: Deploy GCP Infrastructure (First Apply)

Deploy only the GCP resources (network, GKE cluster, database, Redis, storage, secrets) without Kubernetes resources:

```bash
terraform apply \
  -target=google_container_cluster.this \
  -target=google_sql_database_instance.this \
  -target=google_redis_instance.this \
  -target=google_compute_network.this \
  -target=google_compute_subnetwork.this \
  -target=google_storage_bucket.langfuse \
  -target=google_service_account.langfuse \
  -target=google_secret_manager_secret.ee_key \
  -target=google_secret_manager_secret_version.ee_key
```

**Important:** This step will create the GKE cluster and other infrastructure. At the end of the apply, you'll see an output with the **Load Balancer IP address**.

### Step 3: Configure DNS

After the first apply completes, Terraform will output the load balancer IP address. You need to:

1. Create an A record in your DNS provider pointing your domain to this IP address
   - Domain: `langfuse.kouperhealth.com` (or your configured domain)
   - Type: A
   - Value: [IP address from Terraform output]

2. Wait for DNS propagation (can take a few minutes to 48 hours depending on TTL)

### Step 4: Configure kubectl Access to GKE Cluster

Before deploying Kubernetes resources, configure `kubectl` to access your GKE cluster:

```bash
# Get cluster credentials
gcloud container clusters get-credentials <cluster-name> --region <region>

# Verify connection
kubectl get nodes
```

Replace `<cluster-name>` with your cluster name (e.g., `primus-langfuse`) and `<region>` with your GCP region (e.g., `us-central1`).

**Note:** You may need to install the GKE auth plugin if you haven't already:

```bash
gcloud components install gke-gcloud-auth-plugin
```

### Step 5: Deploy Kubernetes Resources (Second Apply)

Once the GKE cluster is running, DNS is configured, and kubectl is set up, deploy the remaining resources:

```bash
terraform plan
terraform apply
```

This will deploy:
- Kubernetes namespace
- Kubernetes secrets (containing database passwords, Redis credentials, etc.)
- Langfuse Helm chart
- TLS certificate
- Ingress configuration

### Step 5: Get the Ingress IP Address

After the Helm chart is deployed, get the ingress IP address:

```bash
kubectl get ingress -n <namespace>
```

Replace `<namespace>` with your Kubernetes namespace (e.g., `primus-langfuse`). The output will show the ingress IP address in the `ADDRESS` column. Use this IP to configure your DNS A record if you haven't already.

### Step 6: Wait for SSL Certificate Provisioning

Google-managed SSL certificates can take 15-60 minutes to provision. Monitor the certificate status:

```bash
gcloud compute ssl-certificates list --project=YOUR_PROJECT_ID
```

Wait until the status shows `ACTIVE`.

### Step 7: Access Langfuse

Once the SSL certificate is active, access Langfuse at:
```
https://langfuse.kouperhealth.com
```

## Outputs

After deployment, Terraform provides these outputs:

- `cluster_name`: GKE cluster name
- `cluster_host`: GKE cluster endpoint
- `ee_key_secret_name`: Name of the GCP Secret Manager secret containing the enterprise encryption key

## Troubleshooting

### Issue: "no client config" error during plan

This occurs when Terraform tries to connect to the GKE cluster before it exists. Solution: Use the two-step deployment approach (Step 2 and Step 4 above).

### Issue: SSL certificate not provisioning

- Verify DNS is correctly configured and propagated
- Check that the domain in `terraform.tfvars` matches your DNS A record
- SSL certificates can take up to 60 minutes to provision

### Issue: Helm chart deployment fails

- Ensure the GKE cluster is fully operational
- Check that all dependencies (database, Redis, storage) are created
- Review Kubernetes events: `kubectl get events -n primus-langfuse`

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning:** This will delete all data including databases. Make sure to backup any important data first.

## Security Notes

- `terraform.tfvars` is gitignored and should never be committed to version control
- The enterprise encryption key in `secrets.tf` should be updated before deployment
- Database passwords and secrets are auto-generated and stored in Kubernetes secrets
- The encryption key for Langfuse is auto-generated by the module and stored securely

## Additional Configuration

### Scaling Configuration

Adjust database and cache resources in `terraform.tfvars`:
- `database_instance_tier`: Machine type for Cloud SQL
- `database_instance_availability_type`: ZONAL or REGIONAL
- `cache_memory_size_gb`: Redis memory size

## Updating Secrets

If you need to update secrets (e.g., enterprise license key, API keys) after deployment:

1. **Update the secret in GCP Secret Manager or Kubernetes:**
   ```bash
   # For GCP Secret Manager secrets
   gcloud secrets versions add <secret-name> --data-file=<path-to-file>
   
   # For Kubernetes secrets
   kubectl edit secret langfuse -n <namespace>
   ```

2. **Restart the Langfuse services to pick up the new secret:**
   ```bash
   # Restart web deployment
   kubectl rollout restart deployment langfuse-web -n <namespace>
   
   # Restart worker deployment
   kubectl rollout restart deployment langfuse-worker -n <namespace>
   ```

3. **Monitor the rollout status:**
   ```bash
   kubectl rollout status deployment langfuse-web -n <namespace>
   kubectl rollout status deployment langfuse-worker -n <namespace>
   kubectl get pods -n <namespace>
   ```

Replace `<namespace>` with your Kubernetes namespace (e.g., `primus-langfuse`).

## Support

For issues specific to this Terraform module, check the main README.md.
For Langfuse-specific issues, visit: https://langfuse.com/docs
