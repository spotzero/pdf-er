#!/bin/bash

openssl req -nodes -newkey rsa:2048 -keyout key.pem -out cert.csr -subj "/OU=David Pascoe-Deslauriers/CN=PDFServe"
openssl x509 -req -days 3650 -in cert.csr -signkey key.pem -out cert.pem
#openssl pkcs12 -export -nodes -in cert.pem -inkey key.pem -out cert.p12 -name "PDFServe" -passout pass:
