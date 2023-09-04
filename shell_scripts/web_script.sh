#!/bin/sh
apt-get update

#DB_PASS=$1
cat <<EOT >> ~/.bashrc
APP_PORT=8080
DB_IP='10.1.1.4'
DB_USER="oriu"
DB_PASS="oriu"
EOT
export APP_PORT=8080
export DB_IP='10.1.1.4'
export DB_USER="oriu"
export DB_PASSWORD="oriu"
apt install nano
apt install python3
apt install python3-pip -y
pip install flask
pip install psycopg2-binary
.~/.bashrc
.web_script.sh
python3 /var/lib/waagent/custom-script/download/0/terraform_project/milkers_flask_app/init_db.py
python3 /var/lib/waagent/custom-script/download/0/terraform_project/milkers_flask_app/milkers.py &
