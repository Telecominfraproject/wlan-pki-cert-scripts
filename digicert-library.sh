#!/bin/bash

: "${DIGICERT_API_KEY:?DIGICERT_API_KEY env variable is not set or empty}"

export SERVER_ENROLLMENT_PROFILE_ID='IOT_5e405ae7-bdbd-46f2-accd-1667d581dfe7'
export CLIENT_ENROLLMENT_PROFILE_ID='IOT_abf4d6c6-2575-462a-9338-f902b42a73d2'
export SERVER_WITH_CLIENT_ENROLLMENT_PROFILE_ID=$SERVER_ENROLLMENT_PROFILE_ID # TODO: create profile with client and server certs
export CNF_DIR="configs"
export CSR_DIR="csr"
export GENERATED_DIR="generated"

function check_command() {
  local command=$1
  if ! command -v "$command" &> /dev/null
  then
      echo "command $command could not be found, please install it"
      exit 1
  fi
}

function new_uuid() {
  tr -dc 'a-zA-Z0-9' < /dev/urandom | fold -w 32 | head -n 1
}

function request_certificate() {
  local csr_file=$1
  local cert_file=$2
  local device_identifier=$3
  local enrollment_profile=$4
  local device_params=$5

  csr_text=$(sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' "$csr_file")

  request=$(cat <<EOF
{
  "csr": "$csr_text",
  "enrollment_profile_id": "$enrollment_profile",
  "device_attributes": [
    {
      "id": "819f33c1-f717-4efe-9f31-78222de5e37a",
      "value": "TIP Open Wi-Fi"
    },
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
    --request POST 'https://one.digicert.com/iot/api/v1/certificate' \
    --header "x-api-key: $DIGICERT_API_KEY" \
    --header "Content-Type: application/json" \
    --data-raw "$request")

  check_command jq
  echo "$response" | tr '\r\n' ' ' | jq --raw-output .pem | awk '{gsub(/\\n/,"\n")}1' > "$cert_file"
}

function extract_single_cert() {
  local fullchain_file_name=$1
  local cacert_file_name=$2

  awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".pem"}' < "$GENERATED_DIR/${fullchain_file_name}.pem"
  cat cert.pem > "$GENERATED_DIR/${fullchain_file_name}.pem"
  cat cert1.pem cert2.pem > "$GENERATED_DIR/${cacert_file_name}.pem"
  rm -rf cert*.pem
}

function get-device-id() {
  local device_identifier=$1
  local save_as=$2

  # YYYY-MM-DD
  today=$(date +%F)

  response=$(curl \
    --silent \
    --request GET "https://one.digicert.com/iot/api/v2/device?limit=1&device_identifier=${device_identifier}&updated_from=$today" \
    --header "x-api-key: $DIGICERT_API_KEY")

  check_command jq
  echo "$response" | jq --raw-output .records[0].id > "${save_as}"
}
