# Cloud-Native Infrastructure Automation & Serverless Container Deployment on AWS

This repository demonstrates the **design, provisioning, and operation of a production-style cloud platform on AWS**, using **Infrastructure as Code, container orchestration, and CI/CD automation**.

The primary goal of this project is to demonstrate **infrastructure design, CI/CD workflows, and service deployment strategies**, rather than application-level complexity.

---

## 🎯 Project Goals

This project was built to demonstrate:

- End-to-end infrastructure provisioning using Terraform
- Running multiple services on ECS Fargate (serverless containers)
- Secure CI/CD pipelines using GitHub Actions
- Clear separation of infrastructure, deployment, and application concerns
- Design decisions and trade-offs commonly made in real-world systems

---

## 🧠 Project Overview

The platform provisions a complete AWS environment capable of running multiple services:

- Frontend service (React + Nginx)
- Backend services (Spring Boot – User & Product)
- Managed database (Amazon RDS)
- Container registry (Amazon ECR)
- Traffic routing (Application Load Balancer)
- Observability (CloudWatch Logs)
- CI/CD automation (GitHub Actions)
- Infrastructure as Code (Terraform)

The current implementation targets a development environment, with the repository structured to support future environments (staging / production).

---

.

## 🏗️ High-Level Architecture
### Runtime Architecture

#### Request flow:
```java
Client
  ↓
Application Load Balancer
  ↓
ECS Fargate Services (Frontend / Backend)
  ↓
Amazon RDS
```

Key characteristics:

- ECS tasks run in private subnets
- Only the ALB is publicly exposed
- Services communicate via internal networking
- Health checks ensure traffic reaches only healthy tasks

📌 (Insert architecture diagram screenshot here)

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

📌 (Insert CI/CD pipeline screenshot here)

## 🧪 CI/CD Pipeline Design

The pipeline is intentionally structured into clear phases:

- Phase 0 – Pipeline context
- Phase 1A – Frontend build 
- Phase 1B – Backend build & tests
- Phase 2 – Docker build, trivy security scan, push to ECR
- Phase 3 – ECS deployment
- Final – Aggregated pipeline result

Matrix jobs are used for homogeneous workloads to keep the pipeline scalable as services grow.

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
├── .github/workflows/
│   └── catalogix-cicd.yaml    # CI/CD pipeline
```

Terraform modules were intentionally avoided to keep the infrastructure explicit and reviewable.

---

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
Trivy security scans and Sonar-based analysis are included but configured as non-blocking.

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

### 7️⃣ Serverless-Aligned Tooling Choices

**Decision**
Persistent tooling infrastructure (e.g., self-hosted SonarQube) was avoided.

**Why**

- Reduces operational overhead
- Keeps infrastructure stateless where possible
- Aligns with serverless principles

**Trade-off**

- Some tooling (e.g., SonarCloud) requires external SaaS integration

**Rationale**
The pipeline is designed to be cloud-native and cost-conscious, while remaining extensible.

### 8️⃣ Observability as a First-Class Concern

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

## Future Improvements

- Multi-environment support (staging / production)
- CloudWatch alarms and dashboards
- Advanced deployment strategies (blue/green, canary)
- Distributed tracing and deeper observability

Notes

Terraform modules were intentionally avoided to keep infrastructure readable and traceable for learning and review purposes.

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
Cloud-Native Infrastructure Automation & Serverless Container Deployment on AWS

Designed and provisioned a cloud-native AWS platform using Terraform with ECS Fargate, ALB, ECR, RDS, and CloudWatch

Built a parallelized CI/CD pipeline in GitHub Actions using matrix jobs to build, scan, containerize, and deploy multiple services

Implemented secure container delivery and rolling ECS deployments, integrating image scanning and zero-downtime updates

Applied production-grade IAM and networking design, enforcing least-privilege roles, private workloads, and controlled ingress