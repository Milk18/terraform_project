#!/bin/bash

export APP_PORT=8080
export DB_IP='10.1.1.4'
export DB_USER="oriu"
export DB_PASSWORD="oriu"

# mount disk commands:
sudo mkfs -t ext4 /dev/sdc
sudo mkdir /data1
sudo mount /dev/sdc /data1


export APP_PORT=8080 DB_IP='10.1.1.4' DB_USER="oriu" DB_PASSWORD="oriu"
