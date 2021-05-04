#!/bin/bash

set -e

# Source helper functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/digicert-library.sh"

# Print usage
if [ $# -lt 1 ]; then
    echo "No arguments provided!"
    echo "Provide the unique ID to revoke all certificates for."
    echo "Usage: $0 <controller-id>"
    exit 1
fi

controller_id=$1

revoke_certificate "server-$controller_id"
revoke_certificate "cassandra-$controller_id"
revoke_certificate "mqtt-$controller_id"
revoke_certificate "postgres-$controller_id"
revoke_certificate "kafka-$controller_id"
