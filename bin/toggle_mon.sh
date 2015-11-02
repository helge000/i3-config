#!/bin/bash

IN="LVDS1"
#EXT="HDMI3"
EXT="DP2"

if (xrandr | grep "$EXT disconnected"); then
      xrandr --output $EXT --off --output $IN --auto --primary
      sleep 1
      killall i3_lemonbar.sh
      killall lemonbar-xft
      sleep 1
      i3 restart
      nitrogen --restore
else
      xrandr --output $IN --off --output $EXT --auto --primary
      sleep 1
      killall i3_lemonbar.sh
      killall lemonbar-xft
      sleep 1
      i3 restart
      nitrogen --restore
fi

# Use hotkeys for acpid switch
# ibm/hotkey LEN0068:00 00000080 00004011
# ibm/hotkey LEN0068:00 00000080 00004010

