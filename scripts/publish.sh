#!/usr/bin/env bash
set -euo pipefail

# Publish @gitlawb/gl and platform packages to npm.
#
# Usage:
#   ./scripts/publish.sh <version>
#
# Example:
#   ./scripts/publish.sh 0.3.7
#
# Prerequisites:
#   - npm logged in with @gitlawb org access
#   - Binaries already built and released to GitHub

VERSION="${1:?Usage: publish.sh <version>}"
RELEASES_BASE="https://github.com/gitlawb/releases/releases/download/v${VERSION}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGES_DIR="${ROOT_DIR}/packages"
WORK_DIR="$(mktemp -d)"

trap "rm -rf ${WORK_DIR}" EXIT

echo "==> Publishing @gitlawb/gl v${VERSION}"
echo "    Download base: ${RELEASES_BASE}"
echo ""

# Map npm package → rust target → archive name
declare -A TARGETS=(
  ["gl-darwin-arm64"]="aarch64-apple-darwin"
  ["gl-darwin-x64"]="x86_64-apple-darwin"
  ["gl-linux-arm64"]="aarch64-unknown-linux-musl"
  ["gl-linux-x64"]="x86_64-unknown-linux-musl"
)

# ── Step 1: Download and extract binaries ────────────────────────────────────

for pkg in "${!TARGETS[@]}"; do
  target="${TARGETS[$pkg]}"
  archive="gitlawb-v${VERSION}-${target}.tar.gz"
  url="${RELEASES_BASE}/${archive}"
  pkg_dir="${PACKAGES_DIR}/${pkg}"

  echo "==> Downloading ${archive}..."
  curl -sSfL -o "${WORK_DIR}/${archive}" "${url}" || {
    echo "    ERROR: Failed to download ${url}"
    echo "    Make sure v${VERSION} is released on GitHub first."
    exit 1
  }

  # Verify checksum if available
  checksum_url="${url}.sha256"
  if curl -sSfL -o "${WORK_DIR}/${archive}.sha256" "${checksum_url}" 2>/dev/null; then
    echo "    Verifying checksum..."
    expected=$(cat "${WORK_DIR}/${archive}.sha256" | awk '{print $1}')
    actual=$(shasum -a 256 "${WORK_DIR}/${archive}" | awk '{print $1}')
    if [ "$expected" != "$actual" ]; then
      echo "    ERROR: Checksum mismatch for ${archive}"
      echo "    Expected: ${expected}"
      echo "    Actual:   ${actual}"
      exit 1
    fi
    echo "    Checksum OK"
  fi

  # Extract binaries into package directory
  echo "    Extracting to ${pkg_dir}..."
  tar -xzf "${WORK_DIR}/${archive}" -C "${WORK_DIR}"
  cp "${WORK_DIR}/gl" "${pkg_dir}/gl"
  cp "${WORK_DIR}/git-remote-gitlawb" "${pkg_dir}/git-remote-gitlawb"
  chmod +x "${pkg_dir}/gl" "${pkg_dir}/git-remote-gitlawb"

  # Clean up extracted files for next iteration
  rm -f "${WORK_DIR}/gl" "${WORK_DIR}/git-remote-gitlawb"

  echo "    OK"
  echo ""
done

# ── Step 2: Update versions in all package.json files ────────────────────────

echo "==> Updating versions to ${VERSION}..."

for pkg in gl gl-darwin-arm64 gl-darwin-x64 gl-linux-arm64 gl-linux-x64; do
  pkg_json="${PACKAGES_DIR}/${pkg}/package.json"
  # Use node for portable JSON editing
  node -e "
    const fs = require('fs');
    const pkg = JSON.parse(fs.readFileSync('${pkg_json}', 'utf8'));
    pkg.version = '${VERSION}';
    if (pkg.optionalDependencies) {
      for (const key of Object.keys(pkg.optionalDependencies)) {
        pkg.optionalDependencies[key] = '${VERSION}';
      }
    }
    fs.writeFileSync('${pkg_json}', JSON.stringify(pkg, null, 2) + '\n');
  "
done

echo "    OK"
echo ""

# ── Step 3: Publish platform packages first ──────────────────────────────────

for pkg in gl-darwin-arm64 gl-darwin-x64 gl-linux-arm64 gl-linux-x64; do
  echo "==> Publishing @gitlawb/${pkg}@${VERSION}..."
  (cd "${PACKAGES_DIR}/${pkg}" && npm publish)
  echo "    OK"
  echo ""
done

# ── Step 4: Publish main wrapper package ─────────────────────────────────────

echo "==> Publishing @gitlawb/gl@${VERSION}..."
(cd "${PACKAGES_DIR}/gl" && npm publish)
echo "    OK"
echo ""

echo "==> Done! Published @gitlawb/gl@${VERSION}"
echo ""
echo "    Install with:"
echo "      npm install -g @gitlawb/gl"
echo "      yarn global add @gitlawb/gl"
echo "      pnpm add -g @gitlawb/gl"
