#!/bin/sh
echo Generating decrypted version of the client key
openssl rsa -passin pass:mypassword -in generated/postgresclientkey.pem -out generated/postgresclientkey_dec.pem

