#!/bin/sh
BASE_DIR=./testCA

#create target directories, set permissions
mkdir -p $BASE_DIR/private
chmod go-rx $BASE_DIR/private

#generate the CA certificate
openssl req -batch -x509 -days 3000 -config configs/openssl-ca.cnf -newkey rsa:4096 -sha256 -out generated/cacert.pem -outform PEM

#move generated certificates into their proper places
cp generated/cacert.pem $BASE_DIR
cp generated/cakey.pem $BASE_DIR/private

#init the certificate database files
touch $BASE_DIR/index.txt
echo '01' > $BASE_DIR/serial.txt

mkdir -p $BASE_DIR/newcerts

