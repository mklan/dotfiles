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

* * * * * ~/.cron/low_battery_warning
