#!/bin/sh
while true; do
  paste -d ' ' /sys/class/power_supply/BAT{0..1}/uevent | tr '=' ' ' | \
      awk '/Charging/{ print($1 "=Charging"); next } { print($1 "=" ($2+$4)/2) }' \
      > "$HOME/.uevent"
  sleep 5
done
