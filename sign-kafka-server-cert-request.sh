#!/bin/sh
openssl ca -batch -key mypassword -config configs/openssl-ca.cnf -policy signing_policy -extensions signing_req_server -out generated/kafkaservercert.pem -infiles csr/kafkaservercert.csr

