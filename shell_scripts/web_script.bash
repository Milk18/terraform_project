#!/bin/bash
apt install nano
apt install python3
apt install python3-pip -y
pip install flask
pip install psycopg2-binary
source /var/lib/waagent/custom-script/download/0/terraform_project/shell_scripts/export_script.bash
python3 /var/lib/waagent/custom-script/download/0/terraform_project/milkers_flask_app/init_db.py
python3 /var/lib/waagent/custom-script/download/0/terraform_project/milkers_flask_app/milkers.py &
