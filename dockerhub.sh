#!/usr/bin/env bash
set -ex

# automate tagging with the short commit hash
docker build --no-cache -t jabahum/epcare-distro:$(git rev-parse --short HEAD) .
docker tag jabahum/epcare-distro:$(git rev-parse --short HEAD) jabahum/epcare-distro
docker push jabahum/epcare-distro:$(git rev-parse --short HEAD)
docker push jabahum/epcare-distro:latest