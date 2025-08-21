#!/bin/sh
# Setup script for Adyen Checkout iOS development
# This script installs git hooks for various validations

set -e  # Exit on error

# Constants
HOOKS_DIR=".git/hooks"
PRE_COMMIT="Scripts/hooks/pre-commit"

# Pre-commit hook responsibilities:
# - Validates branch names follow required patterns
# - Validates 3DS2 SDK versions
# - Validates Adyen SDK versions

# Install git hooks
install_git_hooks() {
  echo "Installing git hooks..."
  
  # Install pre-commit hook
  cp "${PRE_COMMIT}" "${HOOKS_DIR}/pre-commit"
  chmod +x "${HOOKS_DIR}/pre-commit"
  echo "✅ Installed pre-commit hook"
}

# Main execution
main() {
  install_git_hooks
  echo "\n℗️ Environment setup complete."
  echo "ℹ️ Remember to set up your Secrets.{environment}.xcconfig files for local development and update the Secrets.xcconfig import."
}

# Execute main
main
