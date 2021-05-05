#!/bin/bash

# Source configuration
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/digicert-config.sh"

export CNF_DIR="configs"
export CSR_DIR="csr"
export GENERATED_DIR="generated"

DIGICERT_BASE_URL="https://one.digicert.com/iot/api/"

# makes sure that the give command is available on the system
function check_command() {
  local command=$1
  if ! command -v "$command" &> /dev/null
  then
      echo "command $command could not be found, please install it"
      exit 1
  fi
}

check_command jq

# OS compatibility
if [ "$(uname)" == "Darwin" ]; then
  check_command gawk
  check_command gsed
  AWK="gawk"
  SED="gsed"
else
  AWK="awk"
  SED="sed"
fi

# retrieves an ID of a given field in a given enrollment profile
function get_enrollment_profile_field_id() {
  local profile_id=$1
  local field_name=$2

  curl  --silent --request GET "${DIGICERT_BASE_URL}v1/enrollment-profile/$profile_id/enrollment-specification" --header "x-api-key: $DIGICERT_API_KEY" | jq -r ".fields[] | select(.name == \"$field_name\") | .id"
}

# normalizes a MAC address by removing all non alphanumeric and uppercasing all characters
function normalize_mac() {
  local mac=$1
  echo "$mac" | tr -d ":" | tr -d "-" |  tr "[:lower:]" "[:upper:]"
}

function get_certificate_by_device_identifier() {
  local device_identifier=$1
  curl --silent --request GET "https://one.digicert.com/iot/api-ui/v1/certificate?=&device_identifier=${device_identifier}&limit=1&status=ISSUED" --header "x-api-key: $DIGICERT_API_KEY" | jq --raw-output ".records[0].id"
}

# checks whether an issued certificate already exists for the given device identifier
function issued_certificate_exists() {
  local device_identifier=$1
  local certificate_id
  certificate_id=$(get_certificate_by_device_identifier "$device_identifier")

  if [ "$certificate_id" = "null" ]
  then
    return 1
  fi

  return 0
}

# revokes a certificate of the given device identifier
function revoke_certificate() {
  local device_identifier=$1

  echo "revoking certificate for device $device_identifier"

  local certificate_id
  certificate_id=$(get_certificate_by_device_identifier "$device_identifier")

  if [ "$certificate_id" = "null" ]
  then
    echo "certificate for device $device_identifier does not exist or has already been revoked"
    return 0
  fi

  curl \
    --silent \
    --request PUT "${DIGICERT_BASE_URL}v1/certificate/${certificate_id}/revoke" \
    --header "x-api-key: $DIGICERT_API_KEY" \
    --header "Content-Type: application/json" \
    --data-raw '{"reason": "unspecified"}'

  echo "revoked certificate for device $device_identifier"
}

function request_server_certificate() {
  local device_params
  device_params=",
    {
      \"id\": \"$(get_enrollment_profile_field_id "$SERVER_ENROLLMENT_PROFILE_ID" Operator)\",
      \"value\": \"$OPERATOR\"
    }
"

  request_certificate "$1" "$2" "$3" "$4" "$device_params"
}

function request_certificate() {
  local csr_file=$1
  local cert_file=$2
  local device_identifier=$3
  local enrollment_profile=$4
  local device_params=$5

  csr_text=$("$SED" '$!s/$/\\n/' "$csr_file" | tr -d '\n')

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

  cert=$(curl \
    --silent \
    --request POST "${DIGICERT_BASE_URL}v1/certificate" \
    --header "x-api-key: $DIGICERT_API_KEY" \
    --header "Content-Type: application/json" \
    --data-raw "$request" | tr '\r\n' ' ' | jq --raw-output .pem)

  echo "$cert" | "$AWK" '{gsub(/\\n/,"\n")}1' > "$cert_file"
}

function extract_single_cert() {
  local fullchain_file_name=$1
  local cacert_file_name=$2

  "$AWK" 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "cert" n ".pem"}' < "$GENERATED_DIR/${fullchain_file_name}.pem"
  cat cert.pem > "$GENERATED_DIR/${fullchain_file_name}.pem"
  cat cert1.pem cert2.pem > "$GENERATED_DIR/${cacert_file_name}.pem"
  rm -rf cert*.pem
}

# returns the device ID for a given device identifier, no those are not the same things ;)
function get_device_id() {
  local device_identifier=$1

  # YYYY-MM-DD
  today=$(date +%F)

  response=$(curl \
    --silent \
    --request GET "${DIGICERT_BASE_URL}v2/device?limit=1&device_identifier=${device_identifier}&updated_from=$today" \
    --header "x-api-key: $DIGICERT_API_KEY")

  echo "$response" | jq --raw-output .records[0].id
}
