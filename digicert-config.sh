#!/bin/bash

: "${DIGICERT_API_KEY:?DIGICERT_API_KEY env variable is not set or empty}"

# ID of enrollment profile that will be used for server components
export SERVER_ENROLLMENT_PROFILE_ID="IOT_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# ID of enrollment profile that will be used for APs
export CLIENT_ENROLLMENT_PROFILE_ID="IOT_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# operator string that will be set on server devices
export OPERATOR="TIP Open Wi-Fi"