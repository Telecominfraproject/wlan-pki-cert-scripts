#!/bin/sh
openssl ca -batch -key mypassword -config configs/openssl-ca.cnf -policy signing_policy -extensions signing_req_client -out generated/clientcert.pem -infiles csr/clientcert.csr

