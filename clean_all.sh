#!/bin/sh

skipCa=$1

if [ "$skipCa" = "true" ]; then
    find ./generated ! -name "cacert.pem" ! -name "cakey.pem" -type f -exec rm -f {} +
else
    rm -rf testCA
    find ./generated ! -name ".gitkeep" -type f -exec rm -f {} +
fi
find ./csr -name "*.csr" -type f -exec rm -f {} +
