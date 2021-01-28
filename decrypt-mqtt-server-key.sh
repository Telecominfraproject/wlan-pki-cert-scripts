#!/bin/sh
echo Generating decrypted version of the mqtt server key
openssl rsa -passin pass:mypassword -in generated/mqttserverkey.pem -out generated/mqttserverkey_dec.pem

