### check tasks
`crontab -l`

### check tasks for root
`sudo crontab -l`

### edit entries

`crontab -e`

### log

`systemctl status cronie`

### jobs

run every minute a battery check

* * * * * ~/.cron/every1min.sh
0 * * * * ~/.cron/every60min.sh