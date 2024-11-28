#!/usr/bin/env bash
set -ex

# automate tagging with the short commit hash
docker build --platform="linux/amd64" --no-cache -t jabahum/ugandaemr-distro:$(git rev-parse --short HEAD) .
docker tag jabahum/ugandaemr-distro:$(git rev-parse --short HEAD) jabahum/ugandaemr-distro
docker push jabahum/ugandaemr-distro:$(git rev-parse --short HEAD)
docker push jabahum/ugandaemr-distro:latest