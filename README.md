# Jenkins CI/CD + Terraform Mini Project

A small Flask service built, tested and deployed by a Jenkins pipeline, plus a Terraform
configuration that provisions an AWS EC2 web server (Infrastructure as Code).

## Architecture

```
git push --> GitHub --> Jenkins (EC2, :8080)
                          |  Checkout
                          |  Install dependencies
                          |  Test (pytest)
                          |  Build Docker image
                          |  Deploy container (:8000) + health check
                          v
                   Flask container on the same EC2 instance

terraform apply --> AWS: security group + EC2 instance (nginx page) in the default VPC
terraform destroy --> removes them
```

## Repository layout

| Path | Purpose |
|---|---|
| `app.py`, `test_app.py` | Flask app (`/`, `/health`, `/version`) and its pytest tests |
| `requirements.txt`, `requirements-dev.txt` | Runtime and test dependencies |
| `Dockerfile`, `.dockerignore` | Image for the app (non-root, health check, gunicorn) |
| `Jenkinsfile` | Declarative pipeline: Checkout, Install, Test, Build, Deploy |
| `terraform/versions.tf` | Terraform and provider versions, AWS provider |
| `terraform/variables.tf` | Inputs: region, project name, instance type, SSH CIDR, port, key, volume |
| `terraform/main.tf` | AMI lookup, default VPC, security group, EC2 instance with user data |
| `terraform/outputs.tf` | Instance ID, public IP, website URL, security group ID |
| `terraform/terraform.tfvars.example` | Example variable values |
| `scripts/setup-jenkins.sh` | Installs Jenkins, Java, Python tools and Terraform on Ubuntu 24.04 |

## Run the tests locally

```bash
python3 -m venv .venv
. .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements-dev.txt
pytest -v
```

## Terraform workflow

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform output
terraform destroy
```

AWS credentials are read from the environment or `aws configure`. State files and
`terraform.tfvars` are never committed.
