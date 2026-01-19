#!/bin/bash
set -euo pipefail

echo "🔧 Running Sourcery..."

SOURCERY="/usr/local/adyen/bin/sourcery"

# Path to config file (relative to script location)
CONFIG="$(cd "$(dirname "$0")" && pwd)/.sourcery.yml"

"$SOURCERY" --config "$CONFIG"

echo "✅ Sourcery finished successfully"
