#!/bin/bash

#COLOR DEFENITION
NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

warn() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

recommend() {
  echo "RECOMMENDATION:"
  echo -e "\t\t" "$1"
  if [[ -n $2 ]]; then
    echo ""
    echo -e "\t\t\t\t" "$2"
  fi
}

error() {
  echo -e >&2 "${RED}[ERROR]${NC} $1"
  if [[ -n $2 ]]; then
    recommend "$2" "$3"
  fi
  exit 1
}
