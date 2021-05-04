#!/bin/sh
ca_cert="${1:-./testCA/cacert.pem}"

openssl pkcs12 -export -in generated/servercert.pem -inkey generated/serverkey.pem -passin pass:mypassword -passout pass:mypassword -out generated/server.pkcs12 -name 1 -CAfile "${ca_cert}" -caname root -chain

keytool -importkeystore -noprompt -destkeystore generated/server_keystore.jks -srckeystore generated/server.pkcs12 -srcstoretype pkcs12 -srcstorepass mypassword -deststorepass mypassword -deststoretype JKS -alias 1
