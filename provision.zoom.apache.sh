# setup apache (web server)
sudo apt-get -y install apache2
sudo ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
sudo ln -s /etc/apache2/mods-available/socache_shmcb.load /etc/apache2/mods-enabled/socache_shmcb.load
sudo ln -s /etc/apache2/mods-available/cgi.load /etc/apache2/mods-enabled/cgi.load
sudo /etc/init.d/apache2 restart

# setup the default datazoomer site
cd /etc/apache2/sites-enabled && sudo rm -f 000-default*
cd /etc/apache2/sites-enabled && sudo rm -f zoom && sudo ln -s /work/source/libs/datazoomer/setup/apache/zoom zoom.conf
