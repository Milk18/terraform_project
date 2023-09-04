#!/bin/bash
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