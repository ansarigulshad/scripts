#!/bin/bash


# Find Nifi logs older than 2 days and create tar
find /var/log/hadoop/nifi/ -type f -mtime +2 | xargs tar czf /hadoop/nifi-logs-archive/nifi-logs-archive-date-`date +%d-%m-%y`.tar.gz

# Delete nifi logs older than 2 days
find /var/log/hadoop/nifi/ -mtime +2 -exec rm {} \;

# Delete nifi logs older than 10 days
find /hadoop/nifi-logs-archive/ -mtime +10 -exec rm {} \;



# Set Cron to run daily at 1AM
# crontab -e
# 0 1 * * * /path/to/script

