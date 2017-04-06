#!/bin/bash

# assume we are not using apache in a proxy scenario
sudo service apache2 stop && sudo systemctl disable apache2 || true

# setup Nginx with HTTP/2 (web server)
# ref: https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-with-http-2-support-on-ubuntu-16-04
sudo pip install uwsgi
sudo apt-get -y install nginx
sudo service nginx restart

# default site
SITEDIR=/etc/nginx/sites-available
SITEENABLEDDIR=/etc/nginx/sites-enabled


cat <<EOT | sudo tee "$SITEDIR/zoom"
# Configuration for Nginx
server {

    # Running port
    listen 80 default_server;
    listen [::]:80 default_server;

    root /work/web/www;
    index index.html index.htm index.nginx-debian.html;
    server_name _;

    # Settings to by-pass for static files
    location ^~ /static/  {
        root /work/web/www/;

    }

    location ^~ /themes/  {
        root /work/web/;
    }

    # Serve a static file (ex. favico) outside static dir.
    location = /favico.ico  {
        root /app/favico.ico;
    }

    # Proxying connections to application servers
    location / {
        include            uwsgi_params;
        uwsgi_pass         uwsgicluster;

        proxy_redirect     off;
        proxy_set_header   Host \$host;
        proxy_set_header   X-Real-IP \$remote_addr;
        proxy_set_header   X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Host \$server_name;
    }
}
EOT
sudo ln -s "$SITEDIR/zoom" "$SITEENABLEDDIR/zoom"
sudo rm "$SITEENABLEDDIR/default"

cat <<EOT | sudo tee "$SITEDIR/../conf.d/uwsgi.conf"
# Configuration containing list of application servers
upstream uwsgicluster {
    server 127.0.0.1:8080;
    # server 127.0.0.1:8081;
    # ..
    # .
}
EOT

sudo nginx -t && sudo service nginx restart

# prepare uWSGI
UWSGIINI=/work/web/uswgi.ini
UWSGI_SERVICE=/etc/systemd/system/zoom.uwsgi.service
ln -s /work/source/libs/datazoomer/setup/www/index.wsgi /work/web/www/wsgi.py
sudo pip install uwsgi

cat <<EOT | sudo tee "$UWSGIINI"
[uwsgi]
# socket = [addr:port]
socket = 127.0.0.1:8080

# Base application directory
chdir  =  /work/web/www

# master = [master process (true of false)]
master = true

# processes = [number of processes]
processes = 5
EOT

# install the application configuration via SYSTEMD
cat <<EOT | sudo tee "$UWSGI_SERVICE"
[Unit]
Description=uWSGI service for zoom
After=nginx.service

[Service]
ExecStart=$(which uwsgi) --ini /work/web/uswgi.ini --wsgi-file /work/web/www/wsgi.py
# Requires systemd version 211 or newer
RuntimeDirectory=uwsgi
Restart=always
KillSignal=SIGQUIT
Type=notify
StandardError=syslog
NotifyAccess=all

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl enable zoom.uwsgi && sudo systemctl start zoom.uwsgi
