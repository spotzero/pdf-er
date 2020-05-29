#!/bin/bash

if [ -z $ROCKET_PORT ]; then
  ROCKET_PORT=8443
fi

if [ "$SSL" -ne "0" ]; then
  ROCKET_TLS='{certs="/app/bin/cert.pem",key="/app/bin/key.pem"}'
fi 


SCREEN=""
for i in $(seq 0 3)
do
  SCREEN="$SCREEN -screen $i 1280x1024x24"
done
/app/bin/pdfserve
