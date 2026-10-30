#!/usr/bin/env bash
# Installs Jenkins, Java, Python tooling and Terraform on Ubuntu 24.04.
# Run on the EC2 instance:  bash scripts/setup-jenkins.sh
set -euo pipefail

echo "==> Freeing memory: stopping minikube if it exists"
minikube stop 2>/dev/null || true
minikube delete 2>/dev/null || true

echo "==> Base packages"
sudo apt-get update -y
sudo apt-get install -y openjdk-21-jre curl gnupg git unzip \
  python3 python3-venv python3-pip ca-certificates

echo "==> Jenkins repository and install"
sudo install -d -m 0755 /usr/share/keyrings
sudo curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  -o /usr/share/keyrings/jenkins-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins

echo "==> Let Jenkins use Docker"
sudo usermod -aG docker jenkins
sudo systemctl enable --now jenkins
sudo systemctl restart jenkins

echo "==> Terraform repository and install"
curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y terraform

echo
echo "==> Versions"
java -version 2>&1 | head -1
git --version
docker --version
terraform version | head -1
systemctl is-active jenkins

echo
echo "Jenkins is starting (takes about 1 minute). Open http://<EC2-PUBLIC-IP>:8080"
echo "Unlock password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
