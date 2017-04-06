#!/bin/bash

# setup python pip (python package manager)
sudo apt-get -y install python-pip

sudo pip install --upgrade pip
sudo pip install BeautifulSoup
sudo pip install markdown
sudo pip install nose
sudo pip install pyrss2gen
sudo pip install fake-factory
sudo apt-get -y install python-imaging

sudo apt-get -y install build-essential libssl-dev libffi-dev python-dev
sudo pip install bcrypt
sudo pip install -Iv passlib==1.6.2

# setup MariaDB (database engine)
sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://mariadb.mirror.colo-serv.net/repo/10.1/ubuntu xenial main'
sudo apt-get update
echo mariadb-server-10.1 mysql-server/root_password password root | sudo debconf-set-selections
echo mariadb-server-10.1 mysql-server/root_password_again password root | sudo debconf-set-selections
sudo apt-get -y -q install mariadb-server
sudo apt-get -y install python-mysqldb

# Install Locales (used by test harness)
sudo apt-get install language-pack-en-base

# setup datazoomer (python web framework)
echo "create database if not exists zoomdata" | mysql -uroot -proot
echo "create database if not exists test" | mysql -uroot -proot

sudo mkdir /work
sudo chgrp dev /work
sudo chmod 775 /work
sudo chmod g+rws /work

mkdir /work/source
mkdir /work/source/libs
mkdir /work/source/themes
mkdir /work/source/apps

mkdir /work/stage
mkdir /work/stage/libs
mkdir /work/stage/themes
mkdir /work/stage/apps

mkdir /work/lib
mkdir /work/jobs
mkdir /work/log
mkdir /work/systems
mkdir /work/data

git clone https://github.com/hlainchb/datazoomer.git /work/source/libs/datazoomer
cd /work/lib && ln -s /work/source/libs/datazoomer/zoom

chmod +x /work/source/libs/datazoomer/setup/www/index.py
echo /work/lib > dsi.pth
sudo mv dsi.pth /usr/local/lib/python2.7/dist-packages

mkdir /work/web
mkdir /work/web/sites
mkdir /work/web/sites/default
mkdir -p /work/web/sites/localhost/data/buckets
mkdir /work/web/apps
mkdir /work/web/themes
mkdir /work/web/www
mkdir /work/web/www/static

cd /work/web/www/static && ln -s /work/source/libs/datazoomer/setup/www/static/icons
cd /work/web/www/static && ln -s /work/source/libs/datazoomer/setup/www/static/images
cd /work/web/www/static && ln -s /work/source/libs/datazoomer/setup/www/static/dz
cd /work/web/www/static && ln -s /work/source/libs/datazoomer/setup/www/static/jquery
cd /work/web/www/static && ln -s /work/source/libs/datazoomer/setup/www/static/modernizr
cd /work/web/www/static && ln -s /work/source/libs/datazoomer/setup/www/static/boilerplate

cd /work/web/www && ln -s /work/source/libs/datazoomer/setup/www/index.py
cd /work/web/themes && ln -s /work/source/libs/datazoomer/themes/default
echo -e "[sites]\\npath=/work/web/sites" > /work/dz.conf
echo -e "[sites]\\npath=/work/web/sites" > /work/web/dz.conf
cp /work/source/libs/datazoomer/sites/default/site.ini /work/web/sites/default/site.ini

# setup the datazoomer database credential
echo -n "CREATE USER dz@localhost IDENTIFIED BY 'root2';" | mysql -uroot -proot
echo -n "GRANT CREATE, DROP, ALTER, DELETE, INDEX, INSERT, SELECT, UPDATE, CREATE TEMPORARY TABLES, TRIGGER, CREATE VIEW, SHOW VIEW, ALTER ROUTINE, CREATE ROUTINE, EXECUTE, LOCK TABLES ON zoomdata.* TO dz@localhost;" | mysql -uroot -proot
sudo sed -i'' 's|^dbuser=root|dbuser=dz|' /work/web/sites/default/site.ini
sudo sed -i'' 's|^dbpass=|dbpass=root2|' /work/web/sites/default/site.ini

mysql -uroot -proot zoomdata < /work/source/libs/datazoomer/setup/database/setup_mysql.sql
mysql -uroot -proot test < /work/source/libs/datazoomer/setup/database/setup_mysql.sql

echo "127.0.0.1 database" | sudo tee -a /etc/hosts
