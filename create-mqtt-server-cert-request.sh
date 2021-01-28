#!/bin/sh
cnf_file="${1:-configs/mqtt-server.cnf}"

openssl req -batch -config "${cnf_file}" -newkey rsa:2048 -sha256 -out csr/mqttservercert.csr -outform PEM
