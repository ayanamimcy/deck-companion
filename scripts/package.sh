#!/bin/bash
# Build an installable plugin zip: out/deck-companion.zip (same layout as the CI package).
# Decky downloads the dependency bundle listed in package.json's remote_binary from this
# repository's releases at install time (scripts/build-deps.sh builds a new one).
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")/.."

export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
corepack pnpm@10 install --frozen-lockfile >/dev/null
corepack pnpm@10 build >/dev/null

rm -rf out
STAGE=out/_staging/deck-companion
mkdir -p "$STAGE/dist" "$STAGE/py_modules"
cp main.py plugin.json package.json README.md LICENSE THIRD_PARTY_LICENSES "$STAGE/"
cp dist/index.js "$STAGE/dist/"
cp -R py_modules/providers "$STAGE/py_modules/"
find "$STAGE" -type d -name __pycache__ -prune -exec rm -rf {} +
find "$STAGE" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
(cd out/_staging && zip -qr ../deck-companion.zip deck-companion)
rm -rf out/_staging
ls -l out/deck-companion.zip
