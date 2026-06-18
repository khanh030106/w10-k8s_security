#!/bin/bash
# Build and Push API Image to GHCR
# Usage: bash build-and-push.sh <version>

set -e

VERSION=${1:-"v1.0.0"}
GITHUB_USER="khanh030106"  # Đổi thành GitHub username của bạn
IMAGE="ghcr.io/${GITHUB_USER}/w10-api:${VERSION}"

echo "================================================"
echo "Building image: ${IMAGE}"
echo "================================================"

# Build image
cd src/api
docker build -t ${IMAGE} .

echo ""
echo "================================================"
echo "Pushing image: ${IMAGE}"
echo "================================================"

# Push to GHCR
docker push ${IMAGE}

echo ""
echo "================================================"
echo "✅ SUCCESS!"
echo "Image: ${IMAGE}"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Update app-api/rollout.yaml with new image"
echo "2. git add . && git commit -m 'Update image to ${VERSION}'"
echo "3. git push origin main"
