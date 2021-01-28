#!/bin/sh
echo Generating decrypted version of the client key
openssl rsa -passin pass:mypassword -in generated/clientkey.pem -out generated/clientkey_dec.pem

