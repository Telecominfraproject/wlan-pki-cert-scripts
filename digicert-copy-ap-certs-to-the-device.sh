#!/bin/bash

# Source helper functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/digicert-library.sh"

set -e

# Print usage
if [ $# -lt 1 ]; then
    echo "No arguments provided!"
    echo "Usage: $0 <AP host name or IP>"
    exit 1
fi

ap_host="$1"

echo ====================================================
echo Copy generated AP certificates to the device
echo IMPORTANT: this script is naive and assumes you can
echo            connect to the AP with ssh/scp
scp $GENERATED_DIR/cacert.pem root@${ap_host}:/usr/opensync/certs/ca.pem
scp $GENERATED_DIR/clientcert.pem root@${ap_host}:/usr/opensync/certs/client.pem
scp $GENERATED_DIR/clientkey_dec.pem root@${ap_host}:/usr/opensync/certs/client_dec.key
scp $GENERATED_DIR/client_deviceid.txt root@${ap_host}:/usr/opensync/certs/deviceid.txt

