#!/usr/bin/env bash

# rofi-power
# Use rofi to call systemctl for shutdown, reboot, etc

# 2016 Oliver Kraitschy - http://okraits.de

OPTIONS="Reboot system\nPower-off system\nSuspend system\nHibernate system"

#!/usr/bin/bash

# rofi-power
# Use rofi to call systemctl for shutdown, reboot, etc

# 2016 Oliver Kraitschy - http://okraits.de
# Adapted by Matthias Klan 2020

LAUNCHER="rofi -width 20 -height 6 -dmenu -i -p rofi-power"
USE_LOCKER="true"
LOCKER="$HOME/.config/i3/lock.sh"


# Show exit wm option if exit command is provided as an argument
if [ ${#1} -gt 0 ]; then
  OPTIONS="Exit window manager\n$OPTIONS"
fi

option=`echo -e $OPTIONS | $LAUNCHER | awk '{print $1}' | tr -d '\r\n'`
if [ ${#option} -gt 0 ]
then
    case $option in
      Exit)
        eval $1
        ;;
      Reboot)
        systemctl reboot
        ;;
      Power-off)
        systemctl poweroff
        ;;
      Suspend)
        $($USE_LOCKER) && "$LOCKER"; systemctl suspend
        ;;
      Hibernate)
        $($USE_LOCKER) && "$LOCKER"; systemctl hibernate
        ;;
      *)
        ;;
    esac
fi