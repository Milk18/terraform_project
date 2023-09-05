#!/bin/bash
apt install nano
apt install postgresql postgresql-contrib -y
systemctl start postgresql.service
sudo -u postgres psql -c "CREATE DATABASE flask_db;"
sudo -u postgres psql -c "CREATE USER oriu WITH PASSWORD 'oriu';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE flask_db TO oriu;"
echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/*/main/postgresql.conf
echo "host   all    all 10.1.0.0/24     md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf
sudo -u postgres psql -c data_directory = "/data1"
sudo service postgresql restart