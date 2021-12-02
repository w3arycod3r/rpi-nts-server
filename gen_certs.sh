#!/bin/bash
# Generate self-signed certificates for use with NTS and chrony

set -e

server_name=nts-server.local
cert=/etc/ssl/chrony_certs/nts.crt
key=/etc/ssl/chrony_certs/nts.key

rm -f $cert $key

cat > cert.cfg <<EOF
cn = "$server_name"
serial = 001
activation_date = "2020-01-01 00:00:00 UTC"
expiration_date = "2030-01-01 00:00:00 UTC"
signing_key
encryption_key
EOF

certtool --generate-privkey --key-type=ed25519 --outfile $key
certtool --generate-self-signed --load-privkey $key --template cert.cfg --outfile $cert
chmod 640 $cert $key
chown root:_chrony $cert $key

systemctl restart chronyd

sleep 3

chronyc -N authdata


