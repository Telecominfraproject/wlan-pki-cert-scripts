#!/bin/sh
echo Generating decrypted version of the server key
openssl rsa -passin pass:mypassword -in generated/serverkey.pem -out generated/serverkey_dec.pem

