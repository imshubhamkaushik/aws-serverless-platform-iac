# Cloud-Native Infrastructure Automation & Serverless Container Deployment on AWS

This repository contains a **DevOps-focused AWS platform** designed to provision, deploy, and operate multiple application services using **Terraform, ECS Fargate, and GitHub Actions**.

The primary goal of this project is to demonstrate **infrastructure design, CI/CD workflows, and service deployment strategies**, rather than application-level complexity.

---

## 🧠 Project Overview

The platform provisions a complete AWS environment capable of running multiple backend and frontend services with:

- ECS Fargate for containerized workloads
- Application Load Balancer for traffic routing
- Amazon RDS for persistence
- Amazon ECR for container images
- CloudWatch for logs
- GitHub Actions for CI/CD
- Terraform for Infrastructure as Code

The project currently implements a **development environment**, with the folder structure intentionally designed to support additional environments (staging, production) in the future.

---

## 🏗️ Architecture Summary

At a high level:

- Each service (user, product, frontend) is built and containerized independently
- CI pipelines build images and push them to ECR
- ECS services pull images and run tasks in private subnets
- An Application Load Balancer exposes services externally
- RDS provides a managed relational database
- IAM roles are separated for CI, ECS execution, and application runtime

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
│       ├── iam-ci.tf
│       ├── iam-ecs.tf
│       └── cloudwatch.tf
│
├── user-svc/                  # User backend service (Spring Boot)
├── product-svc/               # Product backend service (Spring Boot)
├── frontend-svc/              # Frontend service (React + Nginx)
│
├── .github/workflows/
│   └── catalogix-cicd.yaml    # CI/CD pipeline
```

## CI/CD Pipeline

The GitHub Actions pipeline performs the following:

1. Builds application artifacts
2. Builds Docker images
3. Pushes images to Amazon ECR
4. Deploys updated services to ECS

Key characteristics:

- Matrix builds are used to handle multiple services
- Environment variables and secrets are managed via GitHub Actions secrets
- Infrastructure and application concerns are clearly separated

## Deployment & Rollback Strategy

### Deployment

- ECS services use rolling deployments
- New task definition revisions are registered per deployment
- ALB ensures traffic is routed only to healthy tasks

### Rollback (Conceptual)

- ECS retains previous task definition revisions
- Rollback can be performed by redeploying a previous stable revision
- No additional tooling is required

## Testing

Backend services include basic unit and controller tests to validate core functionality during CI.

Testing is intentionally kept minimal, as the focus of this project is infrastructure and deployment automation.

## Security & IAM

- Separate IAM roles for:
  - CI/CD pipeline
  - ECS task execution
  - Application runtime

- Security groups enforce strict traffic flow:
  - ALB → ECS → RDS

## Future Improvements

- Add staging and production environments
- Add more CloudWatch alarms and metrics
- Explore advanced deployment strategies (blue/green, canary)
- Improve observability and tracing

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
