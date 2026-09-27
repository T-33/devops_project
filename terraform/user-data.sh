#!/bin/bash
set -e

# Update and install Docker
apt-get update -y
apt-get install -y docker.io caddy curl

# Allow 'ubuntu' user to use docker without sudo
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker
systemctl enable caddy
