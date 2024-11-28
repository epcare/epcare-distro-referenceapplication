#!/usr/bin/env bash
set -ex

# automate tagging with the short commit hash
docker build --platform="linux/amd64" --no-cache -t jabahum/ugandaemr-frontend:$(git rev-parse --short HEAD) .
docker tag jabahum/ugandaemr-frontend:$(git rev-parse --short HEAD) jabahum/ugandaemr-frontend
docker push jabahum/ugandaemr-frontend:$(git rev-parse --short HEAD)
docker push jabahum/ugandaemr-frontend:latest