#/bin/bash
# supsend when on Bat power; otherwise lock screen

ac_online=`cat /sys/class/power_supply/AC/online`

if [ $ac_online == 0 ]; then
  /usr/bin/systemctl suspend
else
  /usr/bin/xlock -mode life 
fi
