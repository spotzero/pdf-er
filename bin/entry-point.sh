#!/bin/bash

ROCKET_PORT=8443 ROCKET_TLS={certs="/app/bin/cert.pem",key="/app/bin/key.pem"} /app/bin/pdfserve
