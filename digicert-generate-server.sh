#!/bin/bash

set -e

# Source helper functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/digicert-library.sh"

# Print usage
if [ $# -lt 1 ]; then
    echo "No arguments provided!"
    echo "Provide a unique ID for your controller to create a new set of certificates. If issued certificates exist nothing will be done. Revoke beforehand to recreate certs."
    echo "Usage: $0 <controller-id>"
    exit 1
fi

controller_id=$1

echo ====================================================

device_identifier="server-$controller_id"
if issued_certificate_exists "$device_identifier"; then
    echo Generic Server Certificate already exists, skipping...
else
    echo Creating Generic Server Certificate
    ./create-server-cert-request.sh "$CNF_DIR/digicert-openssl-server.cnf"
    request_server_certificate "$CSR_DIR/servercert.csr" "$GENERATED_DIR/servercert.pem" "$device_identifier" "$SERVER_ENROLLMENT_PROFILE_ID"
    extract_single_cert "servercert" "cacert"
    ./decrypt-server-key.sh
fi

echo ====================================================
device_identifier="mqtt-$controller_id"
if issued_certificate_exists "$device_identifier"; then
    echo MQTT Server Certificate already exists, skipping...
else
    echo Creating MQTT Server Certificate
    ./create-mqtt-server-cert-request.sh "$CNF_DIR/digicert-mqtt-server.cnf"
    request_server_certificate "$CSR_DIR/mqttservercert.csr" "$GENERATED_DIR/mqttservercert.pem" "$device_identifier" "$SERVER_ENROLLMENT_PROFILE_ID"
    extract_single_cert "mqttservercert" "cacert"
    ./decrypt-mqtt-server-key.sh
fi

echo ====================================================
device_identifier="kafka-$controller_id"
if issued_certificate_exists "$device_identifier"; then
    echo Kafka Server Certificate already exists, skipping...
else
    echo Creating Kafka Server Certificate
    ./create-kafka-server-cert-request.sh "$CNF_DIR/digicert-openssl-kafka-server.cnf"
    request_server_certificate "$CSR_DIR/kafkaservercert.csr" "$GENERATED_DIR/kafkaservercert.pem" "$device_identifier" "$SERVER_ENROLLMENT_PROFILE_ID"
    extract_single_cert "kafkaservercert" "cacert"
fi

echo ====================================================
device_identifier="cassandra-$controller_id"
if issued_certificate_exists "$device_identifier"; then
    echo Cassandra Server Certificate already exists, skipping...
else
    echo Creating Cassandra Server Certificate
    ./create-cassandra-server-cert-request.sh "$CNF_DIR/digicert-openssl-cassandra-server.cnf"
    request_server_certificate "$CSR_DIR/cassandraservercert.csr" "$GENERATED_DIR/cassandraservercert.pem" "$device_identifier" "$SERVER_ENROLLMENT_PROFILE_ID"
    extract_single_cert "cassandraservercert" "cacert"
    ./decrypt-cassandra-server-key.sh
fi

echo ====================================================
device_identifier="postgres-$controller_id"
if issued_certificate_exists "$device_identifier"; then
    echo Postgres Client Certificate already exists, skipping...
else
    echo Creating Postgres Client Certificates
    ./create-postgres-client-cert-request.sh "$CNF_DIR/digicert-postgres-client.cnf"
    request_server_certificate "$CSR_DIR/postgresclientcert.csr" "$GENERATED_DIR/postgresclientcert.pem" "$device_identifier" "$SERVER_ENROLLMENT_PROFILE_ID"
    extract_single_cert "postgresclientcert" "cacert"
    ./decrypt-postgres-client-key.sh
fi

echo ====================================================
echo Verifying Server Certificate
./verify-server.sh "$GENERATED_DIR/servercert.pem" "$GENERATED_DIR/cacert.pem"

echo ====================================================
echo Packaging Server Certificates
./package-ca-cert.sh "$GENERATED_DIR/cacert.pem"
./package-server-cert.sh "$GENERATED_DIR/cacert.pem"
./package-kafka-server-cert.sh "$GENERATED_DIR/cacert.pem"
./package-cassandra-server-cert.sh "$GENERATED_DIR/cacert.pem"
./package-postgres-client-cert.sh "$GENERATED_DIR/cacert.pem"

echo ====================================================
echo Creating Client-side truststore
echo This truststore will trust all certificates issued
echo by TIPs DigiCert CA
# using server certificate here for the inter-service communication, make sure that certificate has client key usage enabled
openssl pkcs12 -export -in generated/servercert.pem -inkey generated/serverkey.pem -passin pass:mypassword -passout pass:mypassword -out generated/client.pkcs12 -name clientqrcode -CAfile "$GENERATED_DIR/cacert.pem" -caname root -chain
keytool -importkeystore -destkeystore generated/client_keystore.jks -srckeystore generated/client.pkcs12 -srcstoretype pkcs12 -srcstorepass mypassword -deststorepass mypassword -deststoretype JKS -alias clientqrcode


echo ====================================================
echo All Done

