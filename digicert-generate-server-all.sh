#!/bin/bash

# Source helper functions
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/digicert-library.sh"

set -e

echo ====================================================
echo Creating Generic Server Certificate
./create-server-cert-request.sh "digicert-openssl-server.cnf"
request_certificate "servercert.csr" "servercert.pem" "server-$(new_uuid)" "$SERVER_ENROLLMENT_PROFILE_ID"
extract_single_cert "servercert" "cacert"
./decrypt-server-key.sh

echo ====================================================
echo Creating MQTT Server Certificate
./create-mqtt-server-cert-request.sh "digicert-mqtt-server.cnf"
request_certificate "mqttservercert.csr" "mqttservercert.pem" "mqtt-$(new_uuid)" "$SERVER_ENROLLMENT_PROFILE_ID"
extract_single_cert "mqttservercert" "cacert"
./decrypt-mqtt-server-key.sh

echo ====================================================
echo Creating Kafka Server Certificate
./create-kafka-server-cert-request.sh "digicert-openssl-kafka-server.cnf"
request_certificate "kafkaservercert.csr" "kafkaservercert.pem" "kafka-$(new_uuid)" "$SERVER_ENROLLMENT_PROFILE_ID"
extract_single_cert "kafkaservercert" "cacert"

echo ====================================================
echo Creating Cassandra Server Certificate
./create-cassandra-server-cert-request.sh "digicert-openssl-cassandra-server.cnf"
request_certificate "cassandraservercert.csr" "cassandraservercert.pem" "cassandra-$(new_uuid)" "$SERVER_ENROLLMENT_PROFILE_ID"
extract_single_cert "cassandraservercert" "cacert"
./decrypt-cassandra-server-key.sh

echo ====================================================
echo Creating Postgres Client Certificates
./create-postgres-client-cert-request.sh "digicert-postgres-client.cnf"
request_certificate "postgresclientcert.csr" "postgresclientcert.pem" "postgres-$(new_uuid)" "$SERVER_WITH_CLIENT_ENROLLMENT_PROFILE_ID"
extract_single_cert "postgresclientcert" "cacert"
./decrypt-postgres-client-key.sh

echo ====================================================
echo Verifying Server Certificate
./verify-server.sh servercert.pem cacert.pem

echo ====================================================
echo Packaging Server Certificates
./package-ca-cert.sh cacert.pem
./package-server-cert.sh cacert.pem
./package-kafka-server-cert.sh cacert.pem
./package-cassandra-server-cert.sh cacert.pem
./package-postgres-client-cert.sh cacert.pem

echo ====================================================
echo Creating Client-side truststore
echo This truststore will trust all certificates issued
echo by TIPs DigiCert CA
./package-client-cert.sh cacert.pem

echo ====================================================
echo All Done

