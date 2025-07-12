#!/bin/sh

# CertFP documents:
# https://freenode.net/kb/answer/certfp
# https://libera.chat/guides/certfp

NICK=cebrusfs
CERT_NAME=$HOME/.irssi/certfp.pem

if [ ! -f "$CERT_NAME" ]; then
    openssl req -nodes -newkey rsa:4096 -keyout $CERT_NAME -x509 -out $CERT_NAME -days 3650 -subj "/CN=$NICK"
fi

echo "Use the following command in irssi to add client certificate"
echo "/msg NickServ CERT ADD `openssl x509 -sha1 -noout -fingerprint -in $CERT_NAME | sed -e 's/^.*=//;s/://g'`"
