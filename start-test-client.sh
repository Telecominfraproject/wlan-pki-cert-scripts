#!/bin/sh
openssl s_client -CAfile ./testCA/cacert.pem -cert generated/clientcert.pem -key generated/clientkey.pem -connect 127.0.0.1:4242
