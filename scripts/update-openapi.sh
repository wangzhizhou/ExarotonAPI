#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_SPEC="${ROOT_DIR}/Sources/ExarotonHTTP/openapi.yml"
REMOTE_URL="https://developers.exaroton.com/openapi.yaml"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required" >&2
  exit 1
fi

tmp="$(mktemp)"
cleanup() { rm -f "${tmp}"; }
trap cleanup EXIT

curl -fsSL "${REMOTE_URL}" -o "${tmp}"

if [[ ! -f "${LOCAL_SPEC}" ]]; then
  mkdir -p "$(dirname "${LOCAL_SPEC}")"
  mv "${tmp}" "${LOCAL_SPEC}"
  echo "Created: ${LOCAL_SPEC}"
  exit 0
fi

if shasum -a 256 "${LOCAL_SPEC}" | awk '{print $1}' | grep -qx "$(shasum -a 256 "${tmp}" | awk '{print $1}')"; then
  echo "openapi.yml is already up to date."
  exit 0
fi

mv "${tmp}" "${LOCAL_SPEC}"
echo "Updated: ${LOCAL_SPEC}"
