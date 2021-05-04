#!/bin/bash

set -e

# Print usage
if [ $# -lt 3 ]; then
    echo "No arguments provided!"
    echo "Usage: $0 <manufacturer> <mac-address> <redirector>"
    echo "manufacturer - the manufacturer of your AP device"
    echo "mac-address - the primary MAC address of your AP device"
    echo "redirector - the URL to redirect your device to to get provisioned"
    exit 1
fi

# Source common functions and configuration
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/digicert-config.sh"
source "$DIR/digicert-library.sh"


manufacturer="$1"
mac="$(normalize_mac $2)"
redirector="$3"

extra_ap_params=",
    {
      \"id\": \"$(get_enrollment_profile_field_id $CLIENT_ENROLLMENT_PROFILE_ID Redirector)\",
      \"value\": \"$redirector\"
    },
    {
      \"id\": \"$(get_enrollment_profile_field_id $CLIENT_ENROLLMENT_PROFILE_ID Manufacturer)\",
      \"value\": \"$manufacturer\"
    }
"

# Source helper functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/digicert-library.sh"

echo ====================================================
if issued_certificate_exists "$mac"; then
    echo "Certificate for $mac already exists, revoke to recreate"
else
  echo Creating Client Certificate signed by DigiCert
  openssl req -batch -config "$CNF_DIR/digicert-openssl-client.cnf" -newkey rsa:2048 -sha256 -out "$CSR_DIR/clientcert.csr" -keyout "$GENERATED_DIR/clientkey.pem" -subj "/C=CA/ST=Ontario/L=Ottawa/O=ConnectUs Technologies/CN=$mac" -outform PEM -nodes
  request_certificate "$CSR_DIR/clientcert.csr" "$GENERATED_DIR/clientcert.pem" "$mac" "$CLIENT_ENROLLMENT_PROFILE_ID" "$extra_ap_params"
  extract_single_cert "clientcert" "client_cacert"
  ./decrypt-client-key.sh
fi

echo ====================================================
echo Verifying Client Certificate
./verify-client.sh "$GENERATED_DIR/clientcert.pem" "$GENERATED_DIR/client_cacert.pem"

echo ====================================================
echo Query DigiCert API to get and save the Device ID
device_id=$(get_device_id "$mac")
echo "$device_id" > "$GENERATED_DIR/client_deviceid.txt"

echo ====================================================
echo Verify we can query device info using the generated
echo device key and certificate
curl -X GET "https://clientauth.one.digicert.com/iot/api/v2/device/$device_id" --key "$GENERATED_DIR/clientkey_dec.pem" --cert "$GENERATED_DIR/clientcert.pem"

echo ====================================================
echo Packaging Client Certificates
tar -czf "$GENERATED_DIR/$mac.tar.gz" "$GENERATED_DIR/client_cacert.pem" "$GENERATED_DIR/clientcert.pem" "$GENERATED_DIR/clientkey_dec.pem" "$GENERATED_DIR/client_deviceid.txt"
