#!/bin/bash

# Source helper functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/digicert-library.sh"

CNF_DIR="configs"
CSR_DIR="csr"
GENERATED_DIR="generated"

set -e

echo ====================================================
echo Creating Generic Server Certificate
./create-server-cert-request.sh "$CNF_DIR/digicert-openssl-server.cnf"
request_certificate "$CSR_DIR/servercert.csr" "$GENERATED_DIR/servercert.pem" "server-$(new_uuid)" "$SERVER_ENROLLMENT_PROFILE_ID"
extract_single_cert "servercert" "cacert"
./decrypt-server-key.sh

echo ====================================================
echo Creating MQTT Server Certificate
./create-mqtt-server-cert-request.sh "$CNF_DIR/digicert-mqtt-server.cnf"
request_certificate "$CSR_DIR/mqttservercert.csr" "$GENERATED_DIR/mqttservercert.pem" "mqtt-$(new_uuid)" "$SERVER_ENROLLMENT_PROFILE_ID"
extract_single_cert "mqttservercert" "cacert"
./decrypt-mqtt-server-key.sh

echo ====================================================
echo Creating Kafka Server Certificate
./create-kafka-server-cert-request.sh "$CNF_DIR/digicert-openssl-kafka-server.cnf"
request_certificate "$CSR_DIR/kafkaservercert.csr" "$GENERATED_DIR/kafkaservercert.pem" "kafka-$(new_uuid)" "$SERVER_ENROLLMENT_PROFILE_ID"
extract_single_cert "kafkaservercert" "cacert"

echo ====================================================
echo Creating Cassandra Server Certificate
./create-cassandra-server-cert-request.sh "$CNF_DIR/digicert-openssl-cassandra-server.cnf"
request_certificate "$CSR_DIR/cassandraservercert.csr" "$GENERATED_DIR/cassandraservercert.pem" "cassandra-$(new_uuid)" "$SERVER_ENROLLMENT_PROFILE_ID"
extract_single_cert "cassandraservercert" "cacert"
./decrypt-cassandra-server-key.sh

echo ====================================================
echo Creating Postgres Client Certificates
./create-postgres-client-cert-request.sh "$CNF_DIR/digicert-postgres-client.cnf"
request_certificate "$CSR_DIR/postgresclientcert.csr" "$GENERATED_DIR/postgresclientcert.pem" "postgres-$(new_uuid)" "$SERVER_WITH_CLIENT_ENROLLMENT_PROFILE_ID"
extract_single_cert "postgresclientcert" "cacert"
./decrypt-postgres-client-key.sh

echo ====================================================
echo Verifying Server Certificate
./verify-server.sh $GENERATED_DIR/servercert.pem $GENERATED_DIR/cacert.pem

echo ====================================================
echo Packaging Server Certificates
./package-ca-cert.sh $GENERATED_DIR/cacert.pem
./package-server-cert.sh $GENERATED_DIR/cacert.pem
./package-kafka-server-cert.sh $GENERATED_DIR/cacert.pem
./package-cassandra-server-cert.sh $GENERATED_DIR/cacert.pem
./package-postgres-client-cert.sh $GENERATED_DIR/cacert.pem

echo ====================================================
echo Creating Client-side truststore
echo This truststore will trust all certificates issued
echo by TIPs DigiCert CA
./package-client-cert.sh $GENERATED_DIR/cacert.pem

echo ====================================================
echo All Done

