#!/bin/bash

if [ "x$1" == "x" ]
then
  echo Usage: create-ap-cert.sh ap_inventory_id 
  exit 1
fi 

inventoryId=$1

# create ap_keys directory if it is not present
if [ ! -d ./ap_keys ] 
then
  mkdir ./ap_keys
fi

if [ ! -d ./ap_keys ] || [ !  -w ./ap_keys ] 
then
  echo Cannot write into ./ap_keys directory. Please make sure it exists and is writable.
  exit 1
fi

# Generate certificate request
openssl req -batch -config configs/openssl-client.cnf -newkey rsa:2048 -sha256 -out "ap_keys/csr/$inventoryId-cert.csr" -keyout "ap_keys/$inventoryId-key.pem" -subj "/C=CA/ST=Ontario/L=Ottawa/O=ConnectUs Technologies/CN=$inventoryId" -outform PEM -nodes

# Sign certificate request
openssl ca -batch -key mypassword -config configs/openssl-ca.cnf -policy signing_policy -extensions signing_req_client -out "ap_keys/$inventoryId-cert.pem" -infiles "ap_keys/csr/$inventoryId-cert.csr"

# Create unprotected client key
openssl rsa -passin pass:mypassword -in "ap_keys/$inventoryId-key.pem" -out "ap_keys/$inventoryId-key_dec.pem"

# Optional - Package client key and certificate into PKCS12 format
openssl pkcs12 -export -in "ap_keys/$inventoryId-cert.pem" -inkey "ap_keys/$inventoryId-key.pem" -passin pass:mypassword -passout pass:mypassword -out "ap_keys/$inventoryId.pkcs12" -name clientqrcode -CAfile testCA/cacert.pem -caname root -chain

echo "Created certificates for AP: $inventoryId"

