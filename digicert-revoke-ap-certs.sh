#!/bin/bash

set -e

# Source helper functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/digicert-library.sh"

# Print usage
if [ $# -lt 1 ]; then
    echo "No arguments provided!"
    echo "Usage: $0 <mac-address>"
    echo "mac-address - the primary MAC address of your AP device"
    exit 1
fi

mac="$(normalize_mac "$1")"

revoke_certificate "$mac"
