#!/bin/bash

# create certs directory

# create self signed cert
sudo openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=CA/ST=British Columbia/L=Victoria/O=dsilabs/CN=127.0.0.1" \
    -keyout /work/certs/nginx-selfsigned.key \
    -out /work/certs/nginx-selfsigned.crt

# create strong DH group for PFS
sudo openssl dhparam -out /work/certs/dhparam.pem 2048

# create nginx snippet for cert locations
NGINXDIR=/etc/nginx
cat <<EOT | sudo tee "$NGINXDIR/snippets/self-signed.conf"
# Test Self Signed Certificates
ssl_certificate /work/certs/nginx-selfsigned.crt;
ssl_certificate_key /work/certs/nginx-selfsigned.key;
EOT

cat <<EOT | sudo tee "$NGINXDIR/conf.d/ssl.conf"
# SSL settings
include snippets/self-signed.conf;

ssl_protocols TLSv1.1 TLSv1.2;
# ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
#ssl_ciphers "ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!3DES:!DES:!MD5:!PSK:!RC4:!RSA";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable preloading HSTS for now
add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";
add_header X-Frame-Options SAMEORIGIN;
add_header X-Content-Type-Options nosniff;
add_header X-XSS-Protection "1; mode=block";

ssl_dhparam /work/certs/dhparam.pem;
EOT

# Enable SSL ports
sudo sed -r -i'' 's|80 |443 ssl http2 |' "$NGINXDIR/sites-available/zoom"

cat <<EOT | sudo tee --append "$NGINXDIR/sites-available/zoom"
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    return 301 https://\$server_addr\$request_uri;
}
EOT

sudo nginx -t && sudo service nginx restart
