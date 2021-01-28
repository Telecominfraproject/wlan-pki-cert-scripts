#!/bin/sh
echo Generating decrypted version of the cassandra client/server key
openssl rsa -passin pass:mypassword -in generated/cassandraserverkey.pem -out generated/cassandraserverkey_dec.pem

