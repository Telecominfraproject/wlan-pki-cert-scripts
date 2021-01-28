#!/bin/sh
cnf_file="${1:-configs/openssl-kafka-server.cnf}"

openssl req -batch -config "${cnf_file}" -newkey rsa:2048 -sha256 -out csr/kafkaservercert.csr -outform PEM
