#!/bin/sh
openssl ca -batch -key mypassword -config configs/openssl-ca.cnf -policy signing_policy -extensions signing_req_client -out generated/postgresclientcert.pem -infiles csr/postgresclientcert.csr

rm csr/postgresclientcert.csr
