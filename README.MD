# CSGTest DevOps Exercise

## Architecture
ECS Fargate + RDS PostgreSQL + Secrets Manager deployed via Terraform.
CI/CD with GitHub Actions: develop → test, main → prod.

## Prerequisites
- AWS Account + CLI configured
- Terraform >= 1.5
- Docker
- S3 bucket for Terraform state: `csgtest-tfstate`

## Branching Strategy
| Branch    | Environment | Action             |
|-----------|-------------|-------------------|
| `develop` | test        | Auto-deploy       |
| `main`    | prod        | Deploy + approval |

## Quick Start
1. Clone repo
2. Add GitHub Secrets (AWS keys, DB password)
3. Push to `develop` → triggers test deploy
4. Merge to `main` → triggers prod deploy (with approval)

## Tags
All resources tagged: `name=csgtest`