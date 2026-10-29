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
*/15 * * * * ~/.cron/every15min.sh
0 * * * * ~/.cron/every60min.sh

### Known issue (2026-10): crontab/crond PAM failure

`crontab -l/-e` and all user cron jobs fail with `PAM ERROR (Permission denied)`
since the fprintd install (2025-11-25). Cause: `pam_fprintd.so` was inserted in
`/etc/pam.d/system-auth` between `pam_systemd_home.so` and `pam_unix.so`, but the
`[success=2 …]` jump on the systemd_home line was not adjusted — during
`pam_setcred` (the only auth-stack call crond makes) the jump lands in the
`pam_faillock authfail [default=die]` failure branch and the whole stack dies.

Fix (root): change in `/etc/pam.d/system-auth`:

    -auth      [success=2 default=ignore]    pam_systemd_home.so
    +auth      [success=3 default=ignore]    pam_systemd_home.so

(interactive login/fingerprint is unaffected — only non-auth PAM consumers
like crond are. Until fixed, edit the crontab spool directly:
`/var/spool/cron/matze` is user-writable and crond reloads it via inotify.)