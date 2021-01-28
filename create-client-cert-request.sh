#!/bin/sh
cnf_file="${1:-configs/openssl-client.cnf}"

openssl req -batch -config "${cnf_file}" -newkey rsa:2048 -sha256 -out csr/clientcert.csr -outform PEM -nodes
