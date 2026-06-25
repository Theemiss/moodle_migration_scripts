#!/bin/bash
set -euo pipefail

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y jq curl unzip git awscli
else
  echo "Install jq, curl, unzip, git, and awscli manually."
fi
