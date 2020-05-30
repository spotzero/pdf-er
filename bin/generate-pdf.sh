#!/bin/bash
adduser -D $PDFNAME
su - $PDFNAME -c "PDFNAME=$PDFNAME DEV=$DEV URL=$URL /usr/bin/xvfb-run --auto-servernum --server-args='-screen 0 1280x1024x24' /app/bin/pdf-it.sh"
PIDS=$(ps -o pid,user | grep $PDFNAME | grep -v grep | sed -e 's/^[[:space:]]*//' | cut -d' ' -f1 | xargs)
if [ ! -z $PIDS ]; then
  kill -9  $PIDS
fi
deluser --remove-home $PDFNAME