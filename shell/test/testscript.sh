#/bin/bash

yum install postgres
touch pg.conf
init db
systemctl start postgres
systemctl status postgres
