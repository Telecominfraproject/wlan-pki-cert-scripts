#!/bin/sh
openssl x509 -purpose -in generated/servercert.pem -inform PEM -noout

