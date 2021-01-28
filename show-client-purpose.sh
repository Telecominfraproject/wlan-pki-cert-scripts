#!/bin/sh
openssl x509 -purpose -in generated/clientcert.pem -inform PEM -noout

