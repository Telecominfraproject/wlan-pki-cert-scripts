#!/bin/bash
# Script to copy certs to the respective folders in wlan-cloud-helm folders. 
# Make sure you are in wlan-pki-folder with generated
# Usage: ./copy-certs.sh ${wlan-cloud-helm-dir}
# ./copy-certs.sh $HOME/Tip-Repo/wlan-cloud-helm

if [[ $# -eq 0 ]] ;
then
  echo "*** No Arguments supplied!! Expecting Absolute path of wlan-cloud-helm dir as an argument to the script ***"
  echo "*** Usage: ./copy-certs.sh absolute-path-of-wlan-cloud-helm-dir ***"
  exit 1
fi
echo "==============================================="
echo "Copying certs to opensync-gw-cloud certs folder"
cp generated/cacert.pem generated/clientcert.pem generated/clientkey.pem generated/client_keystore.jks generated/server.pkcs12 generated/truststore.jks "$1"/tip-wlan/charts/opensync-gw-cloud/resources/config/certs
echo "================================================"
echo "Copying certs to opensync-gw-static certs folder"
cp generated/client_keystore.jks generated/server.pkcs12 generated/truststore.jks "$1"/tip-wlan/charts/opensync-gw-static/resources/config/certs
echo "=================================================="
echo "Copying certs to opensync-mqtt-broker certs folder"
cp generated/cacert.pem generated/mqttservercert.pem generated/mqttserverkey_dec.pem "$1"/tip-wlan/charts/opensync-mqtt-broker/resources/config/certs/
echo "====================================================================="
echo "Copying certs to wlan-integrated-cloud-component-service certs folder"
cp generated/client_keystore.jks generated/server.pkcs12 generated/truststore.jks "$1"/tip-wlan/charts/wlan-integrated-cloud-component-service/resources/config/certs/
echo "================================================="
echo "Copying certs to wlan-portal-service certs folder"
cp generated/client_keystore.jks generated/server.pkcs12 generated/truststore.jks "$1"/tip-wlan/charts/wlan-portal-service/resources/config/certs/
echo "==============================================="
echo "Copying certs to wlan-prov-service certs folder"
cp generated/client_keystore.jks generated/server.pkcs12 generated/truststore.jks generated/cacert.pem generated/postgresclientcert.pem generated/postgresclientkey_dec.pem generated/postgresclient.p12 "$1"/tip-wlan/charts/wlan-prov-service/resources/config/certs/
echo "=============================================="
echo "Copying certs to wlan-ssc-service certs folder"
cp generated/client_keystore.jks generated/server.pkcs12 generated/kafka-server.pkcs12 generated/truststore.jks generated/cacert.pem generated/cassandraserverkey_dec.pem generated/cassandraservercert.pem generated/cassandra_server_keystore.jks "$1"/tip-wlan/charts/wlan-ssc-service/resources/config/certs/
echo "=============================================="
echo "Copying certs to wlan-spc-service certs folder"
cp generated/client_keystore.jks generated/server.pkcs12 generated/kafka-server.pkcs12 generated/truststore.jks "$1"/tip-wlan/charts/wlan-spc-service/resources/config/certs/
echo "================================================="
echo "Copying certs to wlan-port-forwarding-gateway-service certs folder"
cp generated/client_keystore.jks generated/server.pkcs12 generated/truststore.jks "$1"/tip-wlan/charts/wlan-port-forwarding-gateway-service/resources/config/certs/
echo "========================================"
echo "Stateful services rework certifices copy"
find ./generated -type f -exec cp {} "$1"/tip-wlan/resources/certs \;
echo "========= All Certs Copied =========="
echo "NOTE: Additional changes are expected in Kafka, Postgres and Cassandra charts before you start deployment. Refer https://telecominfraproject.atlassian.net/wiki/spaces/WIFI/pages/262176803/Pre-requisites+before+deploying+Tip-Wlan+solution"

echo "========= Creating AP Package ======="
cp ./generated/cacert.pem ./generated/ca.pem
cp ./generated/clientcert.pem ./generated/client.pem
cp ./generated/clientkey_dec.pem ./generated/client_dec.key
zip ./generated/ap.zip ./generated/ca.pem ./generated/client.pem ./generated/client_dec.key -j
rm ./generated/ca.pem ./generated/client.pem ./generated/client_dec.key

echo "### OUTDATED, NOT NEEDED ANYMORE"
echo "Copying certs to kafka certs folder"
cp generated/kafka-server.pkcs12 generated/truststore.jks "$1"/tip-wlan/charts/kafka/resources/config/certs/ || true
echo "Copying certs to cassandra certs folder"
cp generated/cassandra_server_keystore.jks generated/truststore.jks generated/cacert.pem generated/cassandraserverkey_dec.pem generated/cassandraservercert.pem "$1"/tip-wlan/charts/cassandra/resources/config/certs/ || true
echo "Copying certs to postgres certs folder"
cp generated/cacert.pem generated/postgresclientcert.pem generated/postgresclientkey_dec.pem generated/servercert.pem generated/serverkey_dec.pem "$1"/tip-wlan/charts/postgresql/resources/config/certs/ || true
