# Cloud-Native Infrastructure Automation & Containerized Deployment on AWS

This repository demonstrates the **design, provisioning, and operation of a production-style cloud platform on AWS**, using **Infrastructure as Code, container orchestration, and CI/CD automation**.

The primary goal of this project is to demonstrate **infrastructure design, CI/CD workflows, and service deployment strategies**, rather than application-level complexity.

---

## 🎯 Project Goals

This project was built to demonstrate:

- End-to-end infrastructure provisioning using Terraform
- Running multiple services on ECS Fargate (serverless containers)
- Secure CI/CD pipelines using GitHub Actions
- DevSecOps practices including vulnerability and IaC scanning
- Production-aligned networking and security design
- Clear separation of infrastructure, deployment, and application concerns
- Design decisions and trade-offs commonly made in real-world systems

---

## 🧠 Project Overview

The platform provisions a complete AWS environment capable of running multiple services:

### Services

- Frontend service (React + Nginx)
- Backend services (Spring Boot – User & Product)

### Platform Components

- Managed database (Amazon RDS PostgreSQL)
- Container runtime (Amazon ECS Fargate)
- Container registry (Amazon ECR)
- Traffic routing (Application Load Balancer)
- Secure credentials (AWS Secrets Manager)
- Observability (CloudWatch Logs and Alarms)
- CI/CD automation (GitHub Actions)
- Infrastructure as Code (Terraform)

The current implementation targets a development environment, with the repository structured to support future environments (staging / production).

---

## 🏗️ High-Level Architecture
### Runtime Architecture

#### Request flow:
```
Client
  ↓
Application Load Balancer
  ↓
ECS Fargate Services (Frontend / Backend) (Private Subnets)
  ↓
Amazon RDS PostgreSQL (Private subnets)
```

#### Key characteristics:

- ALB runs in public subnets.
- ECS services run in private subnets.
- NAT Gateway provides outbound internet access.
- RDS is isolated in private DB subnets, not publicly accessible.
- Services communicate via internal networking.
- Health checks ensure traffic reaches only healthy tasks.

📌 (Insert architecture diagram screenshot here)

---

---

### 🔐 Networking & Security Architecture

#### Network Design

- Custom VPC with CIDR planning
- Public subnets → ALB
- Private app subnets → ECS tasks
- Private DB subnets → RDS
- NAT Gateway for secure outbound traffic
- Internet Gateway for inbound ALB traffic

#### Security Controls

- Least-privilege IAM roles
- ECS accessible only via ALB
- RDS accessible only from ECS
- No public database exposure
- Secrets stored in AWS Secrets Manager
- Private workloads with controlled ingress

---

### ☁️ AWS Infrastructure

Provisioned using Terraform.

#### Compute & Containers

- ECS Cluster (Fargate)
- Service-per-microservice architecture
- Target groups & health checks
- Rolling deployments

#### Database

- Amazon RDS PostgreSQL
- Private subnets only
- Security group isolation
- Credentials stored in Secrets Manager

#### Observability

- CloudWatch log groups per service
- ECS CPU alarms
- ALB health alarms
- Metrics dashboard

---

### 📦 Infrastructure as Code (Terraform)

Terraform provisions:

- VPC & networking
- ECS cluster & services
- ALB & routing
- RDS database
- IAM roles & policies
- ECR repositories
- CloudWatch monitoring
- Secrets Manager

#### Terraform Pipeline Highlights

- Remote state bootstrap (S3 backend)
- Security scanning via tfsec
- Automated plan & apply workflow
- Environment-ready structure
- Re-usable composite GitHub Action

---

## 🔁 CI/CD Architecture

Each commit to the main branch triggers a GitHub Actions workflow that:

1. Builds frontend and backend services
2. Builds Docker images per service
3. Scans images for vulnerabilities
4. Pushes images to Amazon ECR
5. Deploys updated services to ECS using rolling deployments

Key pipeline characteristics:

- Parallel builds using matrix jobs
- Centralized image tagging
- Infrastructure and application pipelines are separated
- Non-blocking quality checks (Sonar)

Two pipelines automate platform and application delivery.

---

### 🏗 Terraform Infrastructure Pipeline

Automates infrastructure provisioning

#### Workflow

1. Bootstrap remote backend (S3)
2. Terraform format and validation
3. Security scan (tfsec)
4. Generate plan artifact
5. Apply on main branch

#### Key Features

- Backend auto-bootstrap
- IaC security scanning
- Artifact-based plan/apply
- Reusable composite GitHub Action

---

### 🧪 Application CI/CD Pipeline Design

The pipeline is intentionally structured into clear phases:

- Phase 0 – Pipeline context
  - Generate versioned image tag
- Phase 1A – Frontend build (NodeJS)
- Phase 1B – Backend build & tests (Maven)
- Phase 2 – Docker build, trivy security scan, push to ECR
  - Build Docker Images
  - Trivy vulnerability scanning
  - Push images to Amazon ECR
- Phase 3 – ECS deployment
  - Update ECS task definitions
  - Deploy new revisions
  - Wait for service stability
- Final Summary 
  - Aggregated pipeline result

Matrix jobs are used for homogeneous workloads to keep the pipeline scalable as services grow.

📌 (Insert CI/CD flow diagram here)

---

### 🔑 Secrets Management

Database credentials are store in AWS Secrets Manager.

ECS tasks retrieve credentials via IAM roles.

No secrets are stored in source code or environment files.

---

### Monitoring and Observability

CloudWatch provides

- Container logs
- ECS CPU Alarms
- Metrics dashboards
- ALB health alarms

Logs enable rapid debugging and operational visibility.

---

## 📂 Repository Structure

```text
.
├── terraform/
│   ├── terraform-backend/     # Terraform remote state bootstrap
│   └── envs/dev/              # Development environment infrastructure
│       ├── networking.tf
│       ├── security-groups.tf
│       ├── alb.tf
│       ├── ecs.tf
│       ├── ecr.tf
│       ├── rds.tf
│       ├── iam-ecs.tf
│       ├── cloudwatch.tf
|       ├── outputs.tf
|       ├── provider.tf
|       ├── variables.tf
|       └── backend.tf
│
├── user-svc/                  # User backend service (Spring Boot)
├── product-svc/               # Product backend service (Spring Boot)
├── frontend-svc/              # Frontend service (React + Nginx)
│
├── .github/
|    ├── workflows/
|    |   ├── catalogix-cicd.yaml  # CI/CD pipeline
|    |   └── tf-infra.yaml        # Infrastructure Pipeline
│    └── actions/
|        └── terraform-setup/
|            └── action.yaml    
```

Terraform modules were intentionally avoided to keep the infrastructure explicit and reviewable.

---

## 🚀 Infrastructure Deployment

### Provision Infrastructure

```bash
cd terraform/envs/dev
terraform init
terraform plan
terraform apply
```

### Required GitHub Secrets

- ```AWS_ACCESS_KEY_ID```
- ```AWS_SECRET_ACCESS_KEY```

---

## 🔄 Deployment & Rollback Strategy

### Deployment

- ECS services use rolling deployments
- New task definition revisions are registered per deployment
- ALB ensures traffic is routed only to healthy tasks

### Rollback (Conceptual)

- ECS retains previous task definition revisions
- Rollback can be performed by redeploying a previous stable revision
- No additional tooling is required

---

## 🧪 Testing

- Backend services include basic unit and integration tests
- CI fails fast on build or test errors
- Testing scope kept minimal to emphasize infrastructure & automation

---

## 🔍 Static Code Analysis

This project integrates Sonar-based static code analysis.

- SonarQube was used locally during development
- CI pipeline steps are SonarCloud-compatible
- Sonar analysis is non-blocking by design

This avoids introducing persistent analysis infrastructure while keeping the pipeline production-ready.

---

## 🧩 Design Decisions & Trade-offs

This project intentionally prioritizes platform engineering clarity over application complexity.
Below are the key architectural decisions and the trade-offs behind them.

### 1️⃣ ECS Fargate over EC2 / EKS

**Decision**
ECS Fargate was chosen as the container runtime instead of EC2-backed ECS or Kubernetes (EKS).

**Why**

- No node management or AMI lifecycle
- Native AWS integration (ALB, IAM, CloudWatch)
- Faster time-to-production for small teams

**Trade-off**

- Less control over underlying compute
- Vendor lock-in compared to Kubernetes

**Rationale**
For a DevOps-focused platform demonstrating AWS-native design, Fargate offers the best balance between operational simplicity and production realism.

### 2️⃣ Single ALB with Path-Based Routing

**Decision**
A single Application Load Balancer routes traffic to multiple services using path-based rules.

**Why**

- Cost-efficient
- Centralized ingress
- Simple to reason about request flow

**Trade-off**

- Shared blast radius if ALB misconfigured
- Less isolation than per-service ALBs

**Rationale**
This reflects a common real-world pattern for early-stage or internal platforms, while remaining extensible for future isolation if required.

### 3️⃣ Matrix-Based CI/CD Pipelines

**Decision**
GitHub Actions matrix jobs are used to build, scan, and deploy multiple services in parallel.

**Why**

- Clear per-service isolation
- Faster pipelines through parallelism
- Scales naturally as services are added

**Trade-off**

- Slightly more complex YAML
- Aggregated job status requires careful handling

**Rationale**
This mirrors how modern CI/CD systems handle microservices without duplicating pipeline logic.

### 4️⃣ Non-Blocking Security & Code Quality Scans

**Decision**
Trivy security scans are included but configured as non-blocking.

**Why**

- Avoids deployment friction during early iterations
- Keeps focus on platform reliability
- Makes pipeline production-ready without enforcing premature gates

**Trade-off**

- Vulnerabilities do not automatically block deployments
- Requires human review or future policy enforcement

**Rationale**
This reflects real-world maturity progression: visibility first, enforcement later.

### 5️⃣ Terraform without Modules (Intentionally)

**Decision**
Terraform modules were intentionally avoided.

**Why**

- Improves readability for reviewers
- Makes resource relationships explicit
- Easier to trace during interviews

**Trade-off**

- Less DRY
- Harder to scale across many environments

**Rationale**
For a learning and portfolio project, transparency was prioritized over abstraction.

### 6️⃣ Minimal Application Logic

**Decision**
Application services are intentionally simple.

**Why**

- Keeps focus on infrastructure, CI/CD, and deployment
- Avoids conflating backend engineering with platform engineering

**Trade-off**

- Limited business logic depth

**Rationale**
The project’s goal is to demonstrate how services are built, shipped, and operated, not feature-rich applications.

### 7️⃣8️⃣ Observability as a First-Class Concern

**Decision**
CloudWatch logging is configured per service with defined retention.

**Why**

- Enables debugging and post-deployment visibility
- Avoids silent failures
- Mirrors production expectations

**Trade-off**

- No advanced tracing or metrics dashboards yet

**Rationale**
Logs are the foundational observability layer and are sufficient for this platform’s scope.

---

## 🧠 Development Environment Constraints

This environment is intentionally optimized for simplicity and cost:

- HTTP only (no ACM/HTTPS)
- No autoscaling
- Single-environment focus (dev only)
- Simplified monitoring
- Minimal operational overhead

These trade-offs reduce operational cost while preserving architectural clarity.

---

## Future Improvements

- Multi-environment support (staging / production)
- HTTPS with ACM
- AWS WAF protection
- Autoscaling policies
- Blue/green or canary deployments
- GitHub OIDC authentication (remove long-lived access keys)
- Advanced metrics and tracing

Notes

Terraform modules were intentionally avoided to keep infrastructure readable and traceable for learning and review purposes. Will introduce later.

---

## 🎯 What This Project Demonstrates

- Cloud-native architecture design
- Infrastructure as Code best practices
- Secure networking & IAM design
- DevSecOps pipeline integration
- Automated container deployments
- Observability & operational readiness
- Platform engineering mindset

---

# 3️⃣ Architecture Diagrams (what to draw + explanation)

You should have **two diagrams**.

---

## 🗺️ Diagram 1: High-Level AWS Architecture

::contentReference[oaicite:0]{index=0}

### Components to include:

- VPC
- Public Subnets → ALB
- Private Subnets → ECS Tasks
- RDS in private subnets
- ECR
- CloudWatch

### Explanation (use this in README / interviews):

> “Client traffic enters through an Application Load Balancer.  
> The ALB routes requests to ECS services running on Fargate in private subnets.  
> Services pull container images from ECR and store data in RDS.  
> Logs are shipped to CloudWatch.”

---

## 🔁 Diagram 2: CI/CD Flow

::contentReference[oaicite:1]{index=1}

### Components:

- Developer
- GitHub Repo
- GitHub Actions
- ECR
- ECS

### Explanation:

> “Each commit triggers a GitHub Actions workflow.  
> The pipeline builds Docker images, pushes them to ECR, and updates ECS services using new task definitions.”

---

<!-- # 4️⃣ Final Level Assessment (precise)

This project is **not beginner**. -->

<!-- ### Where it lies:

**👉 Intermediate (DevOps / Cloud Engineering)**

More specifically:
- **Beginner–Intermediate** ❌ too low
- **Intermediate** ✅ accurate
- **Intermediate–High** ⚠️ only after:
  - multi-env
  - alarms
  - deployment strategies

For someone with **0 YOE**, this project is **above expectation**.

--- -->

<!-- ## Final honest take

You did **infrastructure engineering**, not demo scripting.

Your only missing piece was **storytelling** — and now you have it.

If you want next:
- interview explanations
- resume bullet points
- “how to defend design choices”

Just say the word. -->

### Static Code Analysis

This project integrates Sonar-based static code analysis.

- SonarQube was used locally during development for code quality validation.
- CI pipeline steps are SonarCloud-compatible and can be enabled by providing
  SonarCloud credentials and organization details.
- Sonar analysis is configured as non-blocking to prioritize deployment flow.

This approach avoids introducing persistent analysis infrastructure while
keeping the pipeline production-ready.

🎯 What diagrams you should actually draw (important)

You only need two diagrams. More than that hurts.

1️⃣ High-Level AWS Architecture (MOST IMPORTANT)

Include:

VPC

Public Subnets → ALB

Private Subnets → ECS (Fargate)

RDS

ECR

CloudWatch

IAM roles (simple labels)

Keep it readable in 1 glance.

2️⃣ CI/CD Flow Diagram

Include:

Developer → GitHub

GitHub Actions

Build/Test

Docker Build

ECR

ECS Deploy

This pairs perfectly with your pipeline screenshots.





RESUME BULLETS
Cloud-Native Infrastructure Automation & Containerized Deployment on AWS

Designed and provisioned a cloud-native AWS platform using Terraform with ECS Fargate, ALB, ECR, RDS, and CloudWatch

Built a parallelized CI/CD pipeline in GitHub Actions using matrix jobs to build, scan, containerize, and deploy multiple services

Implemented secure container delivery and rolling ECS deployments, integrating image scanning and zero-downtime updates

Applied production-grade IAM and networking design, enforcing least-privilege roles, private workloads, and controlled ingress

-----
new 18/02

Designed and provisioned a cloud-native AWS platform using Terraform, deploying ECS Fargate microservices behind an Application Load Balancer with a private RDS PostgreSQL database.

Built secure CI/CD pipelines in GitHub Actions to build, scan, containerize, and deploy services with immutable image versioning and zero-downtime ECS rolling deployments.

Implemented production-aligned networking and security, including private subnets, NAT gateway routing, least-privilege IAM roles, and AWS Secrets Manager–based credential management.

Integrated DevSecOps and observability practices by adding container vulnerability scanning (Trivy), Terraform security scanning (tfsec), and CloudWatch logging and alarms for operational visibility.