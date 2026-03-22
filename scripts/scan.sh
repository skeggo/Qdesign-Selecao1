#!/usr/bin/env bash
# Trivy security scan — run against all QDesign images locally.
# Requires: Docker running, images already built via docker compose build.
#
# Usage:
#   ./scripts/scan.sh              # scan all images
#   ./scripts/scan.sh backend-core # scan one image

set -euo pipefail

SEVERITY="${TRIVY_SEVERITY:-HIGH,CRITICAL}"
PROJECT="${COMPOSE_PROJECT_NAME:-qdesign-selecao1}"

SERVICES=(
  backend-core
  ui
  knowledge-service
  retrieval-service
  co-scientist-service
)

# If a specific service was passed, only scan that one
if [ $# -ge 1 ]; then
  SERVICES=("$1")
fi

run_trivy() {
  local image="$1"
  echo ""
  echo "════════════════════════════════════════════════"
  echo "  Scanning: $image"
  echo "════════════════════════════════════════════════"
  docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy:latest image \
    --severity "$SEVERITY" \
    --format table \
    "$image"
}

scan_configs() {
  echo ""
  echo "════════════════════════════════════════════════"
  echo "  Scanning Dockerfiles for misconfigurations"
  echo "════════════════════════════════════════════════"
  docker run --rm \
    -v "$(pwd):/project" \
    aquasec/trivy:latest config \
    --severity "$SEVERITY" \
    /project
}

# Always scan Dockerfiles first
scan_configs

# Scan each image
for svc in "${SERVICES[@]}"; do
  # docker compose names images as <project>-<service>
  image="${PROJECT}-${svc}"

  if docker image inspect "$image" &>/dev/null; then
    run_trivy "$image"
  else
    echo ""
    echo "⚠  Image '$image' not found — run 'docker compose build $svc' first."
  fi
done

echo ""
echo "Scan complete. Check GitHub Security tab for SARIF results in CI."
