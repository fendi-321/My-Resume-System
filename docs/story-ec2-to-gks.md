# 🚀 The Great Migration: From a Lonely EC2 to the GKS Galaxy

> *A story about one PHP resume app, its journey from a single server to the Kubernetes cosmos, and how it saved $335/year along the way.*

---

## 🌱 Chapter 1: The Humble Beginnings

Once upon a time, in the vast cloud of the internet, there lived a small but proud PHP application called **"Online Resume System"**.

It was a simple app — just PHP, MySQL, and vanilla JavaScript. It lived on a single **EC2 t3a.medium** instance, a modest server with 2 vCPUs and 4GB of RAM. Every day, it served resumes, showcased skills, and displayed certifications for its owner, Fendi.

But life on EC2 was... lonely.

```ascii
             🌍 Internet
                │
        ┌───────▼───────┐
        │   Cloudflare   │
        │  (The Gate)   │
        └───────┬───────┘
                │
        ┌───────▼───────┐
        │   🖥️ EC2      │
        │  t3a.medium   │
        │ ┌───────────┐ │
        │ │ PHP + SQL │ │
        │ │ (all in   │ │
        │ │  one box) │ │
        │ └───────────┘ │
        └───────────────┘
```

### The Hidden Struggles

Every night, while the world slept, the little PHP app worried:

- **"What if I crash?"** — There was no one to restart it.
- **"What if everyone visits at once?"** — It couldn't grow beyond its tiny box.
- **"Will anyone update me?"** — Updates meant SSH, manual file copies, and crossed fingers.
- **"Am I worth $60/month?"** — The EC2 + RDS bill felt heavy for a portfolio.

> *"There must be more to life than this,"* the app whispered to the MySQL database.

---

## 💡 Chapter 2: The Discovery of GKS

One day, Fendi discovered something magical: **GKS (Google Kubernetes Service)** — Google's container orchestra.

Imagine GKS as a **starship command center** where instead of one big server, you have many small, smart containers working together:

```ascii
     🚀 GKS: The Kubernetes Starship
     
     ┌──────────────────────────────────┐
     │     🌐 Cloudflare Shield         │
     │        (Free CDN + SSL)          │
     └──────────────┬───────────────────┘
                    │
     ┌──────────────▼───────────────────┐
     │    🛸 Load Balancer              │
     │     (The Spaceport)              │
     └──────────────┬───────────────────┘
                    │
     ┌──────────────▼───────────────────┐
     │  📦 namespace: resume-app        │
     │  ┌──────────────────────────┐   │
     │  │  🟢 POD: resume-app      │   │
     │  │  "The Main Character"    │   │
     │  │  PHP 8.2 + Apache        │   │
     │  │  CPU: 100-250m 🪶        │   │
     │  │  RAM: 128-256Mi          │   │
     │  └────────┬─────────────────┘   │
     │           │                     │
     │  ┌────────▼─────────────────┐   │
     │  │  🔵 POD: MySQL 8.0       │   │
     │  │  "The Librarian"         │   │
     │  │  CPU: 250-500m           │   │
     │  │  RAM: 256-512Mi          │   │
     │  │  Storage: 1Gi 📚         │   │
     │  └─────────────────────────┘   │
     └──────────────────────────────────┘
```

### The Superpowers

| Old Power | New Superpower |
|-----------|---------------|
| 🐢 Manual restart | 🔄 **Self-healing** — crashes? Auto-restarts! |
| 🐘 Big server | 🪶 **Tiny pods** — pay only for what you use |
| 🔒 Fixed size | 📈 **Auto-scale** — grows when busy, shrinks when quiet |
| 🚚 FTP uploads | 🎭 **Rolling updates** — zero downtime deploys |
| ☝️ One copy | 🔁 **Declarative** — Git is your source of truth |

The little app was excited. **This was the way.**

---

## 🏗️ Chapter 3: The Containerization Ceremony

The first step of the journey: **becoming a container**.

> *"Let go of your server dependencies,"* the wise DevOps said. *"Embrace the container."*

```dockerfile
FROM php:8.2-apache          # Born anew from a pure image
RUN a2enmod rewrite           # Carrying forward the Apache blessing
RUN docker-php-ext-install pdo pdo_mysql  # Keeping the MySQL connection
COPY . .                      # All memories preserved
RUN chown -R www-data:www-data assets/images  # Permissions set
EXPOSE 80                     # Open for visitors
CMD ["apache2-foreground"]    # Ready to serve... forever
```

With a single command, the app became **immutable**:

```bash
docker build -t resume-app:latest .
```

> *"I am no longer just files on a disk,"* the app realized. *"I am an **image** — timeless, portable, unchangeable."*

---

## 🚢 Chapter 4: Sailing to Artifact Registry

The image needed a home — a secure harbor where it could be stored and retrieved from anywhere in the cloud.

```bash
docker tag resume-app:latest asia-southeast1-docker.pkg.dev/maffindi/resume-app/resume-app:latest
docker push asia-southeast1-docker.pkg.dev/maffindi/resume-app/resume-app:latest
```

The app was now stored in **Google Artifact Registry** — a library in the sky, accessible from any Kubernetes cluster in the world.

---

## ⚡ Chapter 5: The Cluster Awakens

Now it was time to build the GKS cluster. Fendi chose **Asia-Southeast1 (Singapore)** — close to home, close to visitors.

```bash
gcloud container clusters create resume-app-cluster \
  --region=asia-southeast1 \
  --num-nodes=2 \
  --machine-type=e2-micro \
  --enable-autoscaling \
  --min-nodes=1 --max-nodes=3 \
  --preemptible
```

### What This Means (In Plain English):

| Setting | Translation |
|---------|-------------|
| `--preemptible` | "I'm using spot instances — 60-91% cheaper because Google can reclaim them" |
| `--machine-type=e2-micro` | "2 tiny VMs (0.25 vCPU, 1GB RAM each) — total cost: ~$14/mo" |
| `--min-nodes=1 --max-nodes=3` | "Auto-scales from 1 to 3 nodes depending on traffic" |

> 🔑 **Key Insight**: The old EC2 cost **$35/mo** for one server. Now, up to 3 servers cost **$14/mo**. That's the magic of preemptible + autoscaling.

---

## 🗄️ Chapter 6: The Database Crossing

The most delicate part of any migration: **moving the data**.

In the old world, MySQL lived in **RDS** — a managed database service that cost **$18/mo** just to keep the lights on.

In the new world, MySQL would live **inside the cluster** — no RDS, no extra bill.

### The Init Ritual

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-init                  # The sacred initiation script
  namespace: resume-app
spec:
  template:
    spec:
      containers:
      - name: mysql-init
        image: mysql:8.0
        command:
        - sh -c "mysql -h mysql -u root -prootpassword online_resume_system < /sql/init.sql"
      restartPolicy: Never
```

A **Job** ran, the database was populated, and the old RDS was gently retired.

> **Savings from this step alone**: **$18/mo ($216/yr)** — the cost of Netflix, Spotify, and a coffee every month.

---

## 🌐 Chapter 7: The Cloudflare Alliance

The app now lived in GKS, but how would the world find it?

**Cloudflare** became the shield — the protective barrier between the internet and the cluster:

```
                     🌍 Internet
                        │
                  ┌─────▼─────┐
                  │ Cloudflare │  Free CDN + DDoS protection
                  │  (Shield)  │  + SSL Full (Strict)
                  └─────┬─────┘
                        │
                  ┌─────▼─────┐
                  │  GKE LB   │  Load Balancer ($18/mo)
                  └─────┬─────┘
                        │
                  ┌─────▼─────┐
                  │  Pod 🟢   │  The actual app
                  └───────────┘
```

### Why Cloudflare + GKE is a Power Couple

| Without Cloudflare | With Cloudflare |
|-------------------|-----------------|
| Load Balancer handles ALL traffic | Cloudflare caches 70% of requests |
| SSL certificate management needed | Free SSL, auto-renewed |
| Exposed to DDoS attacks | Enterprise-grade DDoS protection |
| Full bandwidth costs from GCP | CDN serves most content |

> **Network Cost**: Without Cloudflare → ~$30-37/mo. With Cloudflare → ~$18-25/mo. **Savings: ~40%**

---

## 📊 Chapter 8: The Cost Revelation

Let's talk money. **This is where the story gets really good.**

### The Old World (EC2)

```
EC2 t3a.medium    →  $35.04/mo   🖥️ One server, always on, mostly idle
RDS db.t3.micro   →  $18.00/mo   🗄️ Managed database
EBS Storage       →   $2.00/mo   💾 20GB SSD
AMI Backup        →   $5.00/mo   📸 Just in case
─────────────────────────────────────────
Total:            →  $60.04/mo   💸
```

### The New World (GKS)

```
GKE Cluster       →   $0.00/mo   🆓 No cluster management fee
e2-micro × 2      →  $14.00/mo   🪶 Two tiny auto-scaling nodes
PV: mysql (1Gi)   →   $0.12/mo   💿 Database storage
PV: uploads (100Mi) → $0.01/mo   📁 File uploads
Load Balancer     →  $18.00/mo   🌐 Ingress to the cluster
Cloudflare        →   $0.00/mo   🛡️ Free CDN + SSL
─────────────────────────────────────────
Total:            →  $32.13/mo   💵
```

### The Realization

```
  💸 Before:  $60.04/mo
  💵 After:   $32.13/mo
  ────────────────────
  ✨ Saved:   $27.91/mo  ← That's 46% less!
  📅 Yearly:  $335.00/yr ← Enough for domain renewal + bubble tea 🧋
```

> *The little app gasped.* It was paying almost **half** what it used to. And it was getting **more reliability, more features, and more peace of mind.**

| What $335/yr Could Buy |
|------------------------|
| 🍜 ~67 bowls of laksa |
| ☕ ~167 kopi at the local mamak |
| 🌐 ~6 years of domain registration |
| 🎮 A Nintendo Switch game + DLC |

---

## 🛡️ Chapter 9: The Hero's New Powers

With the migration complete, the little PHP app discovered its new superpowers:

### 🦸 Power #1: Self-Healing

If the app pod crashes:
```bash
# Kubernetes says: "I got you."
kubectl get pods -n resume-app
# NAME                          READY   STATUS    RESTARTS
# resume-app-7d4f8b9c6f-abc12   1/1     Running   0       
# Was 1 restart? Old me would be down. New me? Back in 2 seconds.
```

### 🦸 Power #2: Zero-Downtime Deployments

```bash
# Update without a single visitor noticing
kubectl set image deployment/resume-app resume-app=resume-app:new-version -n resume-app
kubectl rollout status deployment/resume-app -n resume-app
# deployment "resume-app" successfully rolled out
```

### 🦸 Power #3: GitOps — Infra as Code

> *"Everything I am is in that YAML file,"* the app said proudly.

**Before**: SSH into EC2, manually fix something, hope you remember what you changed.

**After**: All config lives in Git. `kubectl apply -f k8s/` and the cluster matches the config. No drift. No surprises.

### 🦸 Power #4: Auto-Scaling (HPA)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
spec:
  minReplicas: 1    # Sleepy mode
  maxReplicas: 3    # Ready for the rush
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        averageUtilization: 70
```

When traffic spikes → 3 pods. When quiet → 1 pod. **Pay only for what you need.**

---

## ⚰️ Chapter 10: The Farewell to EC2

The moment of truth. The old EC2 instance was decommissioned.

```bash
# The final checklist
☐  ✅ www.maffindi.com loads from GKE
☐  ✅ All data migrated
☐  ✅ Final snapshot taken (just in case)
☐  🗑️ Terminate EC2 instance
☐  🗑️ Delete RDS instance
☐  🗑️ Release Elastic IP
☐  🗑️ Remove old DNS records
```

*A single tear rolled down the terminal.*

```bash
aws ec2 terminate-instances --instance-ids i-0abcdef1234567890
```

The old server powered down. The new one didn't even notice.

---

## 📈 Epilogue: A Year Later

| Metric | Before (EC2) | After (GKS) |
|--------|-------------|-------------|
| **Monthly cost** | $60.04 | $32.13 |
| **Yearly cost** | $720 | $385 |
| **Uptime** | 99.5% (manual restarts) | 99.99% (auto-healing) |
| **Deploy time** | 15 min (SSH + FTP) | 30 sec (`kubectl apply`) |
| **Scaling** | Manual (resize instance) | Auto (HPA + cluster) |
| **Backups** | Manual AMI (monthly) | CronJob (weekly automated) |
| **Configuration** | Snowflake (config drift) | GitOps (declarative) |

### Lessons Learned

1. **Containers aren't just for big apps.** A simple PHP portfolio can benefit enormously from Kubernetes.
2. **Cost optimization is a journey, not a one-time event.** Preemptible nodes + Autoscaling + Cloudflare = 46% savings.
3. **The best infrastructure is invisible.** When it works, no one notices. When it breaks, everyone does. GKE makes "working" the default.
4. **$335/year matters.** That's not "just coffee money" — that's a meaningful reduction for a personal project.

---

## 🎬 The End... Or Just The Beginning?

The little app is now part of something bigger. It's not just a PHP application anymore — it's a **Kubernetes citizen**. It has siblings (Pods), guardians (Deployments), and a home (Namespace).

But the journey never truly ends...

```
Future Quest Log:
☐  Move DB credentials from ConfigMap to ⚠️ Secret (security!)
☐  Add NetworkPolicy to isolate pods (defense in depth)
☐  Implement HPA for elastic scaling (handle traffic spikes)
☐  Set up MySQL backup CronJob (never lose data)
☐  Install OpenCost for cost visibility (know your spend)
☐  Consider GKE Autopilot (even simpler management)
☐  Enable GCP Budget Alerts ($30/mo threshold)
☐  Build CI/CD pipeline (Cloud Build or GitHub Actions)
☐  CDN cache rules for static assets (faster load times)
```

---

## 📖 Author's Note

This story is based on the real migration of **www.maffindi.com** — a live PHP resume system that runs on GKE, fronted by Cloudflare, and costs about **$32/month** to operate.

The moral of the story?

> **Even small apps deserve big-architecture dreams. And those dreams can actually save you money.**

---

### 📚 References

- **GitHub**: [github.com/fendi-321/My-Resume-System](https://github.com/fendi-321/My-Resume-System)
- **GitLab**: [gitlab.com/fendi-321/My-Resume-System](https://gitlab.com/fendi-321/My-Resume-System)
- **Live Site**: [www.maffindi.com](https://www.maffindi.com)

### 🛠️ Technical Companion

For the detailed technical guide with all commands, YAML manifests, and cost breakdowns, see:
> **[docs/ec2-to-gke-migration-guide.md](ec2-to-gke-migration-guide.md)**

---

> *"From one lonely server to a cluster of containers — the story of a resume app that dared to dream bigger, and saved $335/year in the process."* ✨