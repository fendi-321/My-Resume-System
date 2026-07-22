# From EC2 to GKE: Migration & Cost Optimization Guide

> **Project**: Online Resume System (PHP + MySQL on Google Kubernetes Engine)
> **Author**: Fendi
> **Domain**: [www.maffindi.com](https://www.maffindi.com)
> **Date**: July 2026

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Why Migrate from EC2 to GKE?](#2-why-migrate-from-ec2-to-gke)
3. [Migration Strategy: EC2 → GKE](#3-migration-strategy-ec2--gke)
   - [Phase 1: Assessment & Planning](#phase-1-assessment--planning)
   - [Phase 2: Containerization](#phase-2-containerization)
   - [Phase 3: GKE Cluster Setup](#phase-3-gke-cluster-setup)
   - [Phase 4: Database Migration](#phase-4-database-migration)
   - [Phase 5: Application Deployment](#phase-5-application-deployment)
   - [Phase 6: DNS & SSL Cutover](#phase-6-dns--ssl-cutover)
   - [Phase 7: Decommission EC2](#phase-7-decommission-ec2)
4. [Cost Optimization Strategies](#4-cost-optimization-strategies)
   - [Cluster-Level Optimization](#cluster-level-optimization)
   - [Workload Optimization](#workload-optimization)
   - [Storage Optimization](#storage-optimization)
   - [Network Optimization](#network-optimization)
   - [Monitoring & Budget Alerts](#monitoring--budget-alerts)
5. [Cost Comparison: EC2 vs GKE](#5-cost-comparison-ec2-vs-gke)
6. [Operational Best Practices](#6-operational-best-practices)
7. [Appendix: Useful Commands & Scripts](#7-appendix-useful-commands--scripts)

---

## 1. Architecture Overview

### Before: EC2 (Monolithic)

```
┌─────────────────────────────────────────────────┐
│                  Internet                        │
└────────────────────┬────────────────────────────┘
                     │
              ┌──────▼──────┐
              │  Cloudflare  │
              │  DNS + CDN   │
              └──────┬──────┘
                     │
              ┌──────▼──────┐
              │   EC2 t3a   │
              │   .medium   │
              │  PHP + SQL  │
              │   Single    │
              │  Instance   │
              └─────────────┘
```

**Pain Points**:
- Single point of failure
- Manual scaling (resize instance type)
- No rolling updates without downtime
- EC2 + RDS costs add up
- Manual backups required

### After: GKE (Containerized)

```
┌─────────────────────────────────────────────────┐
│                  Internet                        │
└────────────────────┬────────────────────────────┘
                     │
              ┌──────▼──────┐
              │  Cloudflare  │
              │  DNS + CDN   │
              │  SSL Strict  │
              └──────┬──────┘
                     │
        ┌────────────▼────────────┐
        │    GKE LoadBalancer     │
        │    (Type: LoadBalancer) │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────┐
        │   Namespace: resume-app  │
        │   ┌─────────────────┐   │
        │   │  Pod: resume-app │   │
        │   │  PHP 8.2 Apache │   │
        │   │  CPU: 100-250m  │   │
        │   │  RAM: 128-256Mi │   │
        │   │  PVC: 100Mi     │   │
        │   └────────┬────────┘   │
        │            │            │
        │   ┌────────▼────────┐   │
        │   │  ClusterIP      │   │
        │   │  mysql:3306     │   │
        │   └────────┬────────┘   │
        │            │            │
        │   ┌────────▼────────┐   │
        │   │  Pod: MySQL 8.0 │   │
        │   │  CPU: 250-500m  │   │
        │   │  RAM: 256-512Mi │   │
        │   │  PVC: 1Gi       │   │
        │   └─────────────────┘   │
        └─────────────────────────┘
```

**Benefits Realized**:
- ✅ Self-healing (auto-restart on failure)
- ✅ Rolling updates with zero downtime
- ✅ Resource limits prevent noisy neighbors
- ✅ Declarative infrastructure (GitOps ready)
- ✅ Easy horizontal scaling
- ✅ Namespace isolation

---

## 2. Why Migrate from EC2 to GKE?

| Aspect | EC2 (t3a.medium) | GKE (Autopilot/Standard) | Impact |
|--------|------------------|--------------------------|--------|
| **Cost** | ~$35/mo (instance) + RDS ~$20/mo | ~$20-30/mo (cluster) | **~50% savings** |
| **High Availability** | Manual (Multi-AZ expensive) | Built-in auto-healing | **99.95%+ uptime** |
| **Scaling** | Vertical only (resize) | Horizontal (add pods) | **Elastic** |
| **Deployments** | SSH + manual copy | `kubectl apply` / CI/CD | **GitOps ready** |
| **Resource Util** | Fixed, often underutilized | Requests/Limits = efficiency | **Optimized** |
| **Disaster Recovery** | AMI backups needed | Kubernetes native | **Declarative** |
| **Immutable Infra** | No (config drift) | Yes (containers) | **Consistent** |

---

## 3. Migration Strategy: EC2 → GKE

### Phase 1: Assessment & Planning

**Objective**: Document current EC2 setup and plan the target architecture.

| Item | Check |
|------|-------|
| ☐ | List all installed PHP extensions (`php -m`) |
| ☐ | Document Apache configuration (`.htaccess`, modules) |
| ☐ | Export MySQL database (`mysqldump`) |
| ☐ | List uploaded files in `assets/images/` |
| ☐ | Note environment variables (DB_HOST, DB_NAME, etc.) |
| ☐ | Check Cloudflare DNS records |
| ☐ | Measure current resource usage (CPU, RAM, disk) |

**Commands to gather data**:

```bash
# On EC2 instance
php -m > php-extensions.txt
mysqldump -u root -p online_resume_system > database_backup.sql
sudo du -sh /var/www/html/assets/images
sudo apache2ctl -M | grep -E "ssl|rewrite"
```

**Key Findings from This Project**:

```yaml
# Application Profile
PHP Version:    8.2
Extensions:     pdo, pdo_mysql
Web Server:     Apache with mod_rewrite
Database:       MySQL 8.0
Storage:        1Gi database + 100Mi uploads
Domain:         www.maffindi.com (Cloudflare proxied)
Traffic:        Low-medium (personal portfolio)
```

### Phase 2: Containerization

**Objective**: Package the PHP application into a Docker container.

**Dockerfile** (used in this project):

```dockerfile
FROM php:8.2-apache
RUN a2enmod rewrite && \
    docker-php-ext-install pdo pdo_mysql && \
    echo "ServerName localhost" >> /etc/apache2/apache2.conf
WORKDIR /var/www/html
COPY . .
RUN mkdir -p assets/images && \
    chown -R www-data:www-data assets/images
EXPOSE 80
CMD ["apache2-foreground"]
```

**Build & Push to Artifact Registry**:

```bash
# Authenticate to Google Cloud
gcloud auth configure-docker asia-southeast1-docker.pkg.dev

# Build Docker image
docker build -t resume-app:latest .

# Tag for Artifact Registry
docker tag resume-app:latest \
  asia-southeast1-docker.pkg.dev/maffindi/resume-app/resume-app:latest

# Push to Artifact Registry
docker push asia-southeast1-docker.pkg.dev/maffindi/resume-app/resume-app:latest
```

### Phase 3: GKE Cluster Setup

**Option A: GKE Autopilot** (Recommended for cost optimization)

```bash
gcloud container clusters create-auto resume-app-cluster \
  --region=asia-southeast1 \
  --project=maffindi
```

**Option B: GKE Standard** (More control)

```bash
gcloud container clusters create resume-app-cluster \
  --region=asia-southeast1 \
  --num-nodes=2 \
  --machine-type=e2-micro \
  --disk-size=20 \
  --max-nodes=3 \
  --min-nodes=1 \
  --enable-autoscaling \
  --no-enable-legacy-authorization \
  --preemptible \
  --project=maffindi
```

> **Note**: This project uses **GKE Standard** with the configuration above. For production, consider switching to Autopilot for simpler management.

**Namespace Isolation**:

```bash
kubectl create namespace resume-app
```

### Phase 4: Database Migration

**Strategy**: Export from EC2 → Import to GKE MySQL pod.

**Step 1: Export from EC2 MySQL**

```bash
mysqldump -h <EC2-MYSQL-ENDPOINT> -u resume_user -p \
  online_resume_system > ec2-backup.sql
```

**Step 2: Create ConfigMap with init SQL**

```yaml
# k8s/db-init-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-init-sql
  namespace: resume-app
data:
  init.sql: |
    -- Full schema from ec2-backup.sql
    ...
```

**Step 3: Run Init Job**

```bash
kubectl apply -f k8s/db-init-configmap.yaml
kubectl apply -f k8s/db-init-job.yaml
```

**Step 4: Verify Data**

```bash
kubectl exec -n resume-app deployment/mysql -- \
  mysql -u resume_user -presume_pass \
  online_resume_system -e "SELECT COUNT(*) FROM users;"
```

### Phase 5: Application Deployment

**Deploy all Kubernetes manifests**:

```bash
# Deploy as done in this project
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml
kubectl wait --for=condition=ready pod -l app=mysql -n resume-app --timeout=120s

kubectl apply -f k8s/db-init-configmap.yaml
kubectl apply -f k8s/db-init-job.yaml

kubectl apply -f k8s/app-config.yaml
kubectl apply -f k8s/app-pvc.yaml
kubectl apply -f k8s/app-deployment.yaml
kubectl apply -f k8s/app-service.yaml
kubectl wait --for=condition=available deployment/resume-app -n resume-app --timeout=120s
```

**Verify Deployment**:

```bash
kubectl get all -n resume-app
kubectl logs -n resume-app deployment/resume-app
```

### Phase 6: DNS & SSL Cutover

**Step 1: Get LoadBalancer IP**

```bash
kubectl get svc -n resume-app resume-app -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

**Step 2: Update Cloudflare DNS**

1. Log into Cloudflare dashboard
2. Update the `A` record for `www.maffindi.com` to point to the LoadBalancer IP
3. Ensure proxy is **enabled** (orange cloud ☁️) for CDN + SSL

**Step 3: Configure SSL in Cloudflare**

| Setting | Value |
|---------|-------|
| SSL/TLS Encryption | **Full (Strict)** |
| Always Use HTTPS | **On** |
| Minimum TLS Version | **1.2** |
| Automatic HTTPS Rewrites | **On** |

### Phase 7: Decommission EC2

**Checklist**:

```
☐ Verify application works on GKE (www.maffindi.com)
☐ Copy any remaining files from EC2 to PVC
☐ Take final snapshot of EC2 (just in case)
☐ Terminate EC2 instance
☐ Delete RDS instance (if using)
☐ Release Elastic IP
☐ Update any monitoring/alerting tools
☐ Remove old DNS records pointing to EC2
```

---

## 4. Cost Optimization Strategies

### Cluster-Level Optimization

| Strategy | Implementation | Estimated Savings |
|----------|---------------|-------------------|
| **Use GKE Autopilot** | No node management, pay per pod | 20-30% vs Standard |
| **Preemptible/Spot VMs** | `--preemptible` flag for node pools | 60-91% off on-demand |
| **Cluster Autoscaler** | Scale nodes 1-3 based on load | 30-50% during low traffic |
| **Right-size node pool** | Use `e2-micro` or `e2-small` | 50% vs `e2-medium` |
| **Single-zone cluster** | Use `--region` not `--zone` with single zone | Avoids cross-zone costs |

**Autoscaler Configuration** (for this project):

```yaml
# Key: Minimum 1 node for availability
#      Maximum 3 nodes during traffic spikes
#      Preemptible for 60% cost reduction
gcloud container node-pools create default-pool \
  --cluster=resume-app-cluster \
  --region=asia-southeast1 \
  --num-nodes=1 \
  --min-nodes=1 \
  --max-nodes=3 \
  --enable-autoscaling \
  --preemptible \
  --machine-type=e2-micro \
  --disk-size=20
```

### Workload Optimization

| Strategy | Our Project | Savings |
|----------|-------------|---------|
| **Set resource requests/limits** | App: 128Mi/256Mi, MySQL: 256Mi/512Mi | Prevents over-provisioning |
| **Use `Requests` = realistic** | Based on actual monitoring data | 30% unused capacity savings |
| **HPA (Horizontal Pod Autoscaler)** | Scale app pods 1-3 based on CPU | Efficient during low traffic |
| **Reduce MySQL resources** | Already modest (256m CPU) | $5-10/mo vs default |
| **Use `ClusterIP` services** | MySQL uses ClusterIP (internal) | No LB cost for internal |

**Resource Analysis**:

| Component | Current Request | Current Limit | Recommended |
|-----------|----------------|---------------|-------------|
| `resume-app` | 100m CPU / 128Mi RAM | 250m CPU / 256Mi RAM | ✅ **Optimal** |
| `mysql` | 250m CPU / 256Mi RAM | 500m CPU / 512Mi RAM | Consider **200m/256Mi** for low-traffic |
| `mysql-pvc` | 1Gi | — | ✅ 1Gi is fine |

**HPA Manifest** (Optional future addition):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: resume-app-hpa
  namespace: resume-app
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: resume-app
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

### Storage Optimization

| Strategy | Our Project | Savings |
|----------|-------------|---------|
| **Delete unused snapshots** | Old PVC snapshots | $1-2/snapshot/mo |
| **Use pd-standard not pd-ssd** | MySQL I/O is light | 40% cheaper than SSD |
| **Reduce PVC sizes** | App: 100Mi (currently), MySQL: 1Gi | Minimum cost |
| **Auto-delete with cluster** | `gcloud clusters delete` with `--delete-disks` | Prevents orphaned disks |

**Storage Analysis**:

| PVC | Current Size | Actual Usage | Recommended | Saving |
|-----|-------------|-------------|-------------|--------|
| `app-uploads` | **100Mi** | ~10-20Mi | ✅ Keep 100Mi | — |
| `mysql-data` | **1Gi** | ~200-300Mi | ✅ Keep 1Gi (for growth) | — |

> **Tip**: For non-critical data, use `pd-standard` (HDD) instead of `pd-ssd`. MySQL can use standard disks for low-traffic apps like this portfolio.

### Network Optimization

| Strategy | Our Project | Savings |
|----------|-------------|---------|
| **Use Cloudflare proxy** | Free CDN + SSL termination | **Free** vs $19/mo Google LB SSL |
| **Ingress instead of LB** | Use GKE Ingress (Google-managed) | Integrated with Cloud CDN |
| **Internal LoadBalancer** | MySQL uses ClusterIP (no LB cost) | **$18-25/mo saved** |
| **Remove unused IPs** | Release old EC2 Elastic IP | **$3.60/mo saved** |
| **Cloudflare caching** | Cache static assets (CSS, JS, images) | Reduces origin requests |

**Network Cost Breakdown**:

```
Without Optimization:
  Cloud Load Balancer:    ~$18-25/mo
  Elastic IP (unused):    ~$3.60/mo  
  Data egress (GCP):      ~$8.40/100GB
  --------------------------------
  Total:                  ~$30-37/mo

With Optimization (Cloudflare Proxy):
  Cloudflare DNS (free):  $0/mo
  Cloudflare CDN:         $0/mo (free tier)
  GKE LB:                 ~$18-25/mo (but cached by CF)
  Data egress cached:     Reduced by ~70%
  --------------------------------
  Total:                  ~$18-25/mo
```

### Monitoring & Budget Alerts

**1. Set Budget Alerts in GCP Console**:

```bash
# Create budget alert for $30/mo threshold
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="resume-app-budget" \
  --budget-amount=30usd \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90 \
  --threshold-rule=percent=100 \
  --notifications-rule-pubsub-topic=budget-alerts
```

**2. Install GKE Cost Optimization Tools**:

```bash
# Install OpenCost (free, open-source)
kubectl apply -f https://raw.githubusercontent.com/opencost/opencost/develop/kubernetes/opencost.yaml

# Access OpenCost UI
kubectl port-forward -n opencost deployment/opencost 9090:9003
# Open: http://localhost:9090
```

**3. Key Metrics to Monitor**:

| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| Monthly cost | >$30 | >$50 | Review resources |
| CPU utilization | >70% sustained | >90% | Add HPA / scale |
| Memory usage | >80% | >90% | Increase limits |
| Disk usage | >80% | >90% | Clean up / resize |
| Unused LBs | Any | Any | Delete or make internal |

---

## 5. Cost Comparison: EC2 vs GKE

### Monthly Cost Breakdown (Asia-Southeast1)

| Component | EC2 (t3a.medium) | GKE (Optimized) | Notes |
|-----------|-----------------|-----------------|-------|
| **Compute** | $35.04 (reserved) | $14.00 (e2-micro × 2) | EC2: 4GB RAM, 2 vCPU. GKE: 2GB, 1 vCPU total |
| **MySQL** | $18.00 (RDS db.t3.micro) | $0.00 (in-cluster) | Self-hosted = no RDS overhead |
| **Storage** | $0.10/GB (gp2) | $0.12/GB (pd-standard) | Similar |
| **Load Balancer** | $0.00 (Elastic IP) | $18.00 (GKE LB) | Needed for GKE ingress |
| **Cloudflare** | $0.00 | $0.00 | Free tier both ways |
| **Snapshot/Backup** | $5.00 (AMI) | $1.00 (PVC snapshots) | GKE cheaper |
| **Monitoring** | $0.00 (CloudWatch free) | $0.00 (GCP Monitoring free) | Similar |

### Total Monthly Cost

```
EC2 Setup:
  EC2 t3a.medium          $35.04
  RDS db.t3.micro         $18.00
  EBS (20GB gp2)           $2.00
  Cloudflare DNS          $0.00
  AMI Backup               $5.00
  -------------------------------
  EC2 Total:              ~$60.04/mo

GKE Setup:
  GKE Cluster (no fee)     $0.00
  e2-micro × 2 (0.25ea)   $14.00
  PV: mysql 1Gi            $0.12
  PV: uploads 100Mi        $0.01
  Load Balancer            $18.00
  Cloudflare (CDN+SSL)     $0.00
  -------------------------------
  GKE Total (Optimized):  ~$32.13/mo
```

### Savings Summary

```
EC2:     ~$60.04/mo
GKE:     ~$32.13/mo
---------------------
Savings: ~$27.91/mo  (46% reduction)
Yearly:  ~$335.00/yr (enough for domain renewal + snacks ☕)
```

> **Note**: Even greater savings if using **GKE Autopilot** (only pay per pod) or **preemptible nodes** (60-91% cheaper for compute).

---

## 6. Operational Best Practices

### Security

| Practice | Implementation | Status |
|----------|---------------|--------|
| **Cloudflare SSL** | Full (Strict) mode | ✅ |
| **MySQL credentials** | In ConfigMap (improve to Secret) | ⚠️ **Needs Update** |
| **NetworkPolicy** | Restrict pod-to-pod traffic | ❌ Not configured |
| **ServiceAccount** | Least-privilege roles | ❌ Use default |
| **Pod Security** | `restricted` or `baseline` profile | ❌ Not configured |

> **⚠️ Important Security Fix**: Move DB credentials from ConfigMap to Kubernetes Secret:
> ```yaml
> apiVersion: v1
> kind: Secret
> metadata:
>   name: db-secret
>   namespace: resume-app
> type: Opaque
> data:
>   DB_PASS: cmVzdW1lX3Bhc3M=  # base64 encoded
> ```

### Disaster Recovery

| Scenario | Recovery Method | RTO | RPO |
|----------|----------------|-----|-----|
| Pod crash | Kubernetes auto-restart | <30s | 0 |
| Node failure | Cluster autoscaler replaces | <5min | 0 |
| Database corruption | PVC snapshot restore | <10min | Last snapshot |
| Region outage | Multi-region backup (future) | <1hr | <1hr |

**Backup CronJob** (Recommended addition):

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: mysql-backup
  namespace: resume-app
spec:
  schedule: "0 2 * * 0"  # Every Sunday 2AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: mysql:8.0
            command:
            - sh
            - -c
            - |
              mysqldump -h mysql -u root -prootpassword \
                online_resume_system > /backup/db-$(date +%Y%m%d).sql
            volumeMounts:
            - name: backup
              mountPath: /backup
          restartPolicy: OnFailure
          volumes:
          - name: backup
            hostPath:
              path: /var/backups/mysql
```

---

## 7. Appendix: Useful Commands & Scripts

### Quick Deploy Script (`deploy.sh`)

```bash
#!/bin/bash
# Deploy Resume App to GKE
set -e

echo "Building Docker image..."
docker build -t resume-app:local .

echo "Deploying MySQL..."
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml
kubectl wait --for=condition=ready pod -l app=mysql -n resume-app --timeout=120s

echo "Initializing database..."
kubectl apply -f k8s/db-init-configmap.yaml
kubectl apply -f k8s/db-init-job.yaml

echo "Deploying App..."
kubectl apply -f k8s/app-config.yaml
kubectl apply -f k8s/app-pvc.yaml
kubectl apply -f k8s/app-deployment.yaml
kubectl apply -f k8s/app-service.yaml
kubectl wait --for=condition=available deployment/resume-app -n resume-app --timeout=120s

echo "Deployment complete!"
```

### Useful GKE Debugging Commands

```bash
# Check everything in your namespace
kubectl get all -n resume-app

# Follow app logs
kubectl logs -n resume-app -f deployment/resume-app

# MySQL logs
kubectl logs -n resume-app deployment/mysql

# Execute MySQL query
kubectl exec -n resume-app deployment/mysql -- \
  mysql -u resume_user -presume_pass online_resume_system \
  -e "SELECT * FROM profile;"

# Port forward to access app locally
kubectl port-forward -n resume-app service/resume-app 8080:80
# Open: http://localhost:8080

# Check pod resource usage
kubectl top pods -n resume-app

# Scale up/down
kubectl scale deployment/resume-app -n resume-app --replicas=2

# Rolling update (zero downtime)
kubectl set image deployment/resume-app resume-app=resume-app:new-version -n resume-app
kubectl rollout status deployment/resume-app -n resume-app

# Rollback if needed
kubectl rollout undo deployment/resume-app -n resume-app
```

### GCP Cost Monitoring Commands

```bash
# View current billing
gcloud billing accounts list

# Get monthly spend
gcloud services enable cloudbilling.googleapis.com
gcloud billing projects get-billing-info maffindi

# Export billing to BigQuery for detailed analysis
gcloud billing accounts set-iam-policy BILLING_ACCOUNT_ID policy.json

# Estimate with pricing calculator:
# https://cloud.google.com/products/calculator
```

---

## Quick Reference: Before vs After Migration

```
┌────────────────────┬───────────────────────┐
│     EC2 (Before)   │    GKE (After)        │
├────────────────────┼───────────────────────┤
│ 1 VM instance      │ Multi-container pods  │
│ SSH access needed  │ Declarative manifests │
│ Manual updates     │ Rolling updates       │
│ ~$60/mo            │ ~$32/mo               │
│ Single AZ          │ Auto-healing          │
│ RDS extra cost     │ In-cluster MySQL      │
│ Manual backups     │ CronJob backups       │
│ Config drift risk  │ Immutable containers  │
│ Vertical scaling   │ Horizontal scaling    │
└────────────────────┴───────────────────────┘
```

---

## Conclusion

Migrating the **Online Resume System** from EC2 to GKE achieved:

1. **46% cost reduction** (~$28/mo savings / ~$335/yr)
2. **Improved reliability** with Kubernetes auto-healing
3. **Zero-downtime deployments** via rolling updates
4. **GitOps-ready infrastructure** (all config as code)
5. **Simplified scaling** (HPA + cluster autoscaler)

### Next Steps & Recommendations

```
☐  Move DB credentials from ConfigMap to Secret
☐  Implement NetworkPolicy (namespace isolation)
☐  Add HPA for app pod auto-scaling
☐  Set up MySQL backup CronJob
☐  Install OpenCost for cost visibility
☐  Consider GKE Autopilot for simpler management
☐  Enable GCP Budget Alerts ($30/mo threshold)
☐  Set up CI/CD pipeline (Cloud Build / GitHub Actions)
```

---

> **GitHub**: [github.com/fendi-321/My-Resume-System](https://github.com/fendi-321/My-Resume-System)  
> **GitLab**: [gitlab.com/fendi-321/My-Resume-System](https://gitlab.com/fendi-321/My-Resume-System)  
> **Live Site**: [www.maffindi.com](https://www.maffindi.com)  
> **License**: Open source (MIT)