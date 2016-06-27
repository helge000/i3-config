#!/bin/bash

IN="eDP-1"
EXT="DP-2-2"

if (xrandr | grep "$EXT connected"); then
  xrandr --output $IN --off --output ${EXT} --auto --primary
  #killall compton
  #compton -CGb --backend glx --vsync opengl --xrender-sync
  i3 restart
  nitrogen --restore
else
  xrandr --output ${EXT} --off --output $IN --auto --primary
  #killall compton
  #compton -CGb --backend glx --vsync opengl --xrender-sync
  i3 restart
  nitrogen --restore
fi

