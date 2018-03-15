#!/bin/sh

set -x

SERVER_URL="localhost"
PASSWORD="tratata"

COUNTRY="UA"
STATE="Kyiv"
LOCALITY="Kyiv"
ORGANIZATION="SomeOrg"
ORGANIZATION_UNIT="SomeUnit"
COMMON=${SERVER_URL}
EMAIL="example@email.com"

# generate private key
openssl genrsa -des3 -out server.key -passout pass:${PASSWORD} 1024

# Generate a CSR (Certificate Signing Request)
openssl req -new -key server.key -subj req -new \
    -passin pass:${PASSWORD} -out server.csr \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${ORGANIZATION_UNIT}/CN=${COMMON}/emailAddress=${EMAIL}"

# Remove Passphrase from Key
cp server.key server.key.org
openssl rsa -in server.key.org -passin pass:${PASSWORD} -out server.key

# Generating a Self-Signed Certificate
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

# Transform to JKS file
openssl pkcs12 -export -name server -in server.crt -inkey server.key -out server.p12 -password pass:${PASSWORD}
keytool -importkeystore -destkeystore server.jks -srckeystore server.p12 -srcstoretype pkcs12 -alias server -deststorepass ${PASSWORD} -srcstorepass ${PASSWORD}

# Copy to staticItems archieve 1
cp ~/server.crt ~/Home/jobs/staticItems/builds/1/archive/keys.crt