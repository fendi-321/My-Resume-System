# Online Resume System — Architecture Diagram (Mermaid)

## 1. High-Level System Architecture (GKE Deployment)

```mermaid
graph TB
    User["🧑‍💻 User Browser"]

    subgraph Cloudflare["☁️ Cloudflare (CDN / SSL)"]
        CF["https://www.maffindi.com<br/>SSL: Full (Strict)"]
    end

    subgraph GCP["☁️ Google Cloud Platform"]
        AR["📀 Artifact Registry<br/>resume-app:latest"]

        subgraph GKE["☸️ GKE Cluster"]
            subgraph NS["📦 Namespace: resume-app"]
                SVC["🔀 Service: resume-app<br/>type: LoadBalancer<br/>80→80, 443→443"]

                subgraph AppDeploy["Deployment: resume-app"]
                    APP["🟢 Pod: resume-app<br/>🐘 Apache + mod_ssl<br/>PHP 8.2 + PDO MySQL"]
                end

                subgraph MySQLDeploy["Deployment: mysql"]
                    MYSQL["🟢 Pod: mysql<br/>🗄️ MySQL 8.0"]
                end

                DBSVC["📦 Service: mysql<br/>ClusterIP :3306"]
                CM["⚙️ ConfigMap: app-config<br/>DB_HOST, DB_NAME<br/>DB_USER, APP_URL"]
                JOB["✅ Job: db-init<br/>(runs init.sql once)"]
                JOBCM["📄 ConfigMap: db-init-sql"]
                PVC1["💾 PVC: app-uploads<br/>RWO 100Mi"]
                PVC2["💾 PVC: mysql-data<br/>RWO 1Gi"]
            end
        end
    end

    User -->|HTTPS request| CF
    CF -->|DNS A record| SVC
    SVC --> APP
    CM -.->|env vars| APP
    PVC1 -.->|mount:<br/>assets/images| APP
    APP -->|PDO :3306| DBSVC
    DBSVC --> MYSQL
    PVC2 -.->|mount:<br/>/var/lib/mysql| MYSQL
    JOBCM -.-> JOB
    JOB -->|mysql -h mysql| DBSVC
    AR -.->|image pull| APP
```

## 2. CI/CD & Build Flow

```mermaid
flowchart LR
    DEV["👨‍💻 Developer"] -->|git push| REPO["📁 Source Repo<br/>(GitHub/GitLab)"]
    REPO --> BUILD["🐳 docker build<br/>Dockerfile: php:8.2-apache"]
    BUILD --> PUSH["📀 Push image to<br/>Artifact Registry"]
    PUSH --> DEPLOY["☸️ kubectl apply<br/>k8s manifests"]
    DEPLOY --> CLUSTER["GKE Cluster<br/>namespace: resume-app"]
```

## 3. Application Request Flow (App ↔ Database)

```mermaid
sequenceDiagram
    participant B as Browser
    participant CF as Cloudflare
    participant LB as LoadBalancer (Service)
    participant Pod as resume-app Pod (PHP)
    participant DBSvc as mysql Service
    participant DB as MySQL Pod

    B->>CF: HTTPS request (www.maffindi.com)
    CF->>LB: Forward via DNS A record
    LB->>Pod: Route to Apache/PHP
    Pod->>DBSvc: PDO query (:3306)
    DBSvc->>DB: Forward to MySQL 8.0
    DB-->>DBSvc: Result set
    DBSvc-->>Pod: Result set
    Pod-->>LB: Rendered HTML/PHP response
    LB-->>CF: HTTP response
    CF-->>B: HTTPS response (cached/SSL)
```

## 4. Kubernetes Resource Relationships

```mermaid
graph LR
    NS["Namespace: resume-app"]

    NS --> D1["Deployment: resume-app"]
    NS --> D2["Deployment: mysql"]
    NS --> S1["Service: resume-app (LB)"]
    NS --> S2["Service: mysql (ClusterIP)"]
    NS --> CM1["ConfigMap: app-config"]
    NS --> CM2["ConfigMap: db-init-sql"]
    NS --> J1["Job: db-init"]
    NS --> P1["PVC: app-uploads"]
    NS --> P2["PVC: mysql-data"]

    D1 --> Pod1["Pod: resume-app"]
    D2 --> Pod2["Pod: mysql"]

    S1 --> Pod1
    S2 --> Pod2

    CM1 -.-> Pod1
    P1 -.-> Pod1
    P2 -.-> Pod2
    CM2 -.-> J1
    J1 --> S2
```
