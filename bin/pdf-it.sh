#!/bin/bash

if [ -f "/output/$PDFNAME.pdf" ]; then
    rm /output/$PDFNAME.pdf
fi

if [ ! -z $PROXY_USER ]; then
    export HTTP_PROXY="http://$PROXY_USER:$PROXY_PASS@$PROXY_HOST"
    export https_proxy="http://$PROXY_USER:$PROXY_PASS@$PROXY_HOST"
    export http_proxy="http://$PROXY_USER:$PROXY_PASS@$PROXY_HOST"
    export HTTPS_PROXY="http://$PROXY_USER:$PROXY_PASS@$PROXY_HOST"
fi

is_dev() {
    if [ $DEV -ne 1 ]; then
        return 1
    fi
    return 0
}

if [ -z $URL ]; then
    URL="https://github.com/"
fi

if [ -z $PDFNAME ]; then
    PDFNAME="default"
fi

PROFILE="/home/$PDFNAME/.mozilla/firefox"
mkdir -p $PROFILE

cp /app/firefox/base/user.js "$PROFILE"
echo "user_pref(\"print.print_to_filename\", \"/output/$PDFNAME.pdf\");" >> "$PROFILE/user.js"

## Start Firefox
firefox -profile "$PROFILE" "$URL" &>/dev/null &
sleep 4
is_dev && import -window root /output/$PDFNAME-1.jpg

if [ ! -z $PROXY_USER ]; then
    # Authenticate to proxies
    xdotool type "$PROXY_USER"
    sleep 1
    xdotool key "Tab"
    sleep 1
    xdotool type "$PROXY_PASS"
    sleep 1
    is_dev && import -window root /output/$PDFNAME-2.jpg
    xdotool key --clearmodifiers "Return"
 fi

sleep 20
is_dev && import -window root /output/$PDFNAME-3.jpg

xdotool  key --clearmodifiers "ctrl+p"
is_dev && import -window root /output/$PDFNAME-4.jpg
sleep 1

xdotool key --clearmodifiers "Tab" key --clearmodifiers "Return"
is_dev && import -window root /output/$PDFNAME-5.jpg

sleep 10
xdotool key --clearmodifiers "ctrl+q"
xdotool key --clearmodifiers "Return"
is_dev && import -window root /output/$PDFNAME-6.jpg