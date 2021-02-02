#!/bin/bash

: "${DIGICERT_API_KEY:?DIGICERT_API_KEY env variable is not set or empty}"

SERVER_ENROLLMENT_PROFILE_ID='IOT_f6305673-f3e0-4cc7-98dd-7b510bc6b6ca'
CLIENT_ENROLLMENT_PROFILE_ID='IOT_9f2b75b7-7816-4640-afbd-0c6e6e42cbb0'
SERVER_WITH_CLIENT_ENROLLMENT_PROFILE_ID='IOT_1da99ee7-a886-4471-8c6f-56aa0cf21bf6'
CNF_DIR="configs"
CSR_DIR="csr"
GENERATED_DIR="generated"

function new_uuid() {
  cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
}

function request_certificate() {
  local csr_file=$1
  local cert_file=$2
  local device_identifier=$3
  local enrollment_profile=$4
  local device_params=$5

  csr_text=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' $csr_file)

  request=$(cat <<EOF
{
  "csr": "$csr_text",
  "enrollment_profile_id": "$enrollment_profile",
  "device_attributes": [
    {
      "id": "DEVICE_IDENTIFIER",
      "value": "$device_identifier"
    }$device_params
  ]
}
EOF
)
  response=$(curl \
    --silent \
    --request POST 'https://demo.one.digicert.com/iot/api/v1/certificate' \
    --header "x-api-key: $DIGICERT_API_KEY" \
    --header "Content-Type: application/json" \
    --data-raw "$request")

  echo $response | tr '\r\n' ' ' | jq --raw-output .pem | awk '{gsub(/\\n/,"\n")}1' > $cert_file
}

function extract_single_cert() {
  local fullchain_file_name=$1
  local cacert_file_name=$2

  cat generated/${fullchain_file_name}.pem | awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".pem"}'
  cat cert.pem > generated/${fullchain_file_name}.pem
  cat cert1.pem cert2.pem > generated/${cacert_file_name}.pem
  rm -rf cert*.pem
}

function get-device-id() {
  local device_identifier=$1
  local save_as=$2

  # YYYY-MM-DD
  today=$(date +%F)

  response=$(curl \
    --silent \
    --request GET "https://demo.one.digicert.com/iot/api/v2/device?limit=1&device_identifier=${device_identifier}&created_from=$today" \
    --header "x-api-key: $DIGICERT_API_KEY")

  echo $response | jq --raw-output .records[0].id > "${save_as}"
}
