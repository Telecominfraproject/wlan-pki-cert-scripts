#!/bin/sh
openssl s_server -CAfile ./testCA/cacert.pem -cert generated/servercert.pem -key generated/serverkey.pem -port 4242
