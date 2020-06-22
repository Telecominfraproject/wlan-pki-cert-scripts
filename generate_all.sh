echo ====================================================
echo Cleaning up old files
./clean_all.sh

echo ====================================================
echo Creating Certificate Authority
./create-ca.sh
cp testCA/cacert.pem cacert.pem

echo ====================================================
echo Creating Generic Server Certificate
./create-server-cert-request.sh
./sign-server-cert-request.sh
./decrypt-server-key.sh

echo ====================================================
echo Creating MQTT Server Certificate
./create-mqtt-server-cert-request.sh
./sign-mqtt-server-cert-request.sh
./decrypt-mqtt-server-key.sh

echo ====================================================
echo Creating Kafka Server Certificate
./create-kafka-server-cert-request.sh
./sign-kafka-server-cert-request.sh

echo ====================================================
echo Creating Cassandra Server Certificate
./create-cassandra-server-cert-request.sh
./sign-cassandra-server-cert-request.sh
./decrypt-cassandra-server-key.sh

echo ====================================================
echo Creating Client Certificate
./create-client-cert-request.sh
./sign-client-cert-request.sh
./decrypt-client-key.sh

echo ====================================================
echo Verifying Server Certificate
./verify-server.sh servercert.pem

echo ====================================================
echo Verifying Client Certificate
./verify-client.sh clientcert.pem

echo ====================================================
echo Packaging Server Certificates
./package-server-cert.sh
./package-kafka-server-cert.sh
./package-cassandra-server-cert.sh

echo ====================================================
echo Packaging Client Certificate
./package-client-cert.sh

echo ====================================================
echo Packaging CA Certificate
./package-ca-cert.sh

echo ====================================================
echo All Done

