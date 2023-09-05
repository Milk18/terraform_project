#!/bin/bash
apt install nano
apt install python3
apt install python3-pip -y
pip install flask
pip install psycopg2-binary
source /var/lib/waagent/custom-script/download/0/terraform_project/shell_scripts/export_script.bash "$1" "$2" "$3" "$4" "$5"
python3 /var/lib/waagent/custom-script/download/0/terraform_project/milkers_flask_app/init_db.py
python3 /var/lib/waagent/custom-script/download/0/terraform_project/milkers_flask_app/milkers.py &

#if for some reason the web vm has crashed we need to do the following steps:
#1. sudo -s (in order to run commands in root shell)
#2. export APP_PORT=8080 DB_IP=10.1.1.4 DB_USER=oriu DB_PASS=* WEB_SNET=10.1.0.0/24
#make sure the values are correct according to your terraform variables.tf and names from your export script (DB_PASS is secret :)
#3. python3 /var/lib/waagent/custom-script/download/0/terraform_project/milkers_flask_app/milkers.py &
# of course you need to make sure that all of the envs in the export command are correct and that your db is up and running
# you should also run the script as root and in background in order for it to work properly
