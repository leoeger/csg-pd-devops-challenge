# csgtest-devops

PagerDuty CSG Innovation Team — DevOps Take-Home Exercise

## Overview

Containerized infrastructure on AWS provisioned with Terraform and deployed
through automated GitHub Actions CI/CD pipelines. Two isolated environments
(test and production) following AWS and DevOps best practices.

## Architecture
Internet
|
v
ALB (public subnet, port 80)
|
v
ECS Fargate (public subnet, assign_public_ip=true)
|
v
RDS PostgreSQL (private subnet, port 5432)

## Tools & Technologies

| Tool | Purpose |
|---|---|
| AWS ECS Fargate | Container orchestration |
| AWS RDS PostgreSQL | Database |
| AWS Secrets Manager | Secure credentials storage |
| AWS ALB | Load balancer |
| AWS ECR | Docker image registry |
| AWS IAM | Roles and least-privilege policies |
| Terraform | Infrastructure as Code |
| GitHub Actions | CI/CD pipelines |
| Docker | Application containerization |

## Repository Structure
csgtest-devops/
├── .github/
│   └── workflows/
│       ├── deploy-prod.yml   # Triggered on push to main
│       └── deploy-test.yml   # Triggered on push to develop
├── terraform/
│   ├── modules/
│   │   ├── ecs/              # ECS cluster, task definition, ALB
│   │   ├── rds/              # RDS instance, subnet group
│   │   ├── networking/       # VPC, subnets, IGW, security groups
│   │   └── secrets/          # AWS Secrets Manager
│   └── environments/
│       ├── prod/             # Production environment
│       └── test/             # Test environment
├── app/
│   ├── Dockerfile
│   ├── docker-entrypoint.sh
│   └── index.html
└── README.md

## Branching Strategy

| Branch | Environment | Pipeline |
|---|---|---|
| `main` | Production | Automatic + manual approval |
| `develop` | Test | Automatic |
| `feature/*` | Local / PR | No automatic deployment |

## Prerequisites

- AWS CLI configured
- Terraform >= 1.5
- Docker Desktop
- GitHub account

## Quick Start

### 1. Create required AWS resources

```bash
aws s3api create-bucket --bucket csgtest-tfstate --region us-east-1
aws s3api put-bucket-versioning \
  --bucket csgtest-tfstate \
  --versioning-configuration Status=Enabled

aws ecr create-repository --repository-name csgtest-app --region us-east-1
```

### 2. Build and push Docker image

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS \
  --password-stdin YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --push \
  -t YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/csgtest-app:test-latest \
  ./app
```

### 3. Deploy infrastructure

```bash
cd terraform/environments/test
terraform init
terraform apply
```

### 4. Verify deployment

```bash
curl http://$(terraform output -raw app_url | sed 's|http://||')
```

## Environment Configuration

| Parameter | Test | Production |
|---|---|---|
| ECS CPU | 256 | 512 |
| ECS Memory | 512 MB | 1024 MB |
| ECS Replicas | 1 | 2 |
| RDS Instance | db.t3.micro | db.t3.small |
| RDS Multi-AZ | No | Yes |

## CI/CD Pipeline

### GitHub Actions Secrets required

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS access key |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key |
| `DB_PASSWORD` | Database password |

### Pipeline flow
Push to develop
└── Build Docker image (linux/amd64)
└── Push to ECR (:test-latest)
└── Terraform apply (test environment)
└── ECS force new deployment
Push to main
└── Build Docker image (linux/amd64)
└── Push to ECR (:prod-latest)
└── Manual approval gate
└── Terraform apply (prod environment)
└── ECS force new deployment

## Security

- IAM roles with least-privilege policies per service
- Credentials stored in AWS Secrets Manager, never in source code
- VPC network segmentation with security groups per layer
- Terraform state encrypted at rest in S3 with versioning
- RDS in private subnet, only accessible from ECS security group
- Docker images built for linux/amd64 using buildx

## Resource Tagging

All AWS resources are tagged with:
name        = csgtest
environment = test | prod
managed_by  = terraform
project     = csgtest-devops

## Application URLs

| Environment | URL |
|---|---|
| Test | http://alb-test-876769746.us-east-1.elb.amazonaws.com |
| Production | http://alb-prod-976800409.us-east-1.elb.amazonaws.com |

## Known Limitations

- ECS runs in public subnets with assign_public_ip=true for simplified
  connectivity. In production this would use private subnets with NAT Gateway.
- GitHub Actions uses AWS Access Keys. Production would use OIDC
  for keyless authentication.
- The Hello World app receives DB_PASSWORD via Secrets Manager
  but does not consume it as it has no backend logic.

## Author

Leonel Gutierrez Roco
April 2026
