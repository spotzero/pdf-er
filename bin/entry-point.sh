#!/bin/bash

if [ -z $ROCKET_PORT ]; then
  ROCKET_PORT=8443
fi

if [ "$SSL" -ne "0" ]; then
  ROCKET_TLS='{certs="/app/bin/cert.pem",key="/app/bin/key.pem"}'
fi 

/app/bin/pdfserve