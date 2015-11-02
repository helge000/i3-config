#! /bin/bash
#
# I3 bar with https://github.com/LemonBoy/bar

. $(dirname $0)/i3_lemonbar_config

if [ $(pgrep -cx $(basename $0)) -gt 1 ] ; then
    printf "%s\n" "The status bar is already running." >&2
    exit 1
fi

trap 'trap - TERM; kill 0' INT TERM QUIT EXIT

[ -e "${panel_fifo}" ] && rm "${panel_fifo}"
mkfifo "${panel_fifo}"

### EVENTS METERS

# Window title, "WIN"
#xprop -spy -root _NET_ACTIVE_WINDOW | sed -un 's/.*\(0x.*\)/WIN\1/p' > "${panel_fifo}" &
while true; do echo "WIN0" > "${panel_fifo}"; sleep 5; done &

# i3 Workspaces, "WSP"
# TODO : Restarting I3 breaks the IPC socket con. :(
$(dirname $0)/i3_workspaces.pl > "${panel_fifo}" &

# IRC, "IRC"
# only for init
#~/bin/irc_warn &

# Conky, "SYS"
conky -c $(dirname $0)/i3_lemonbar_conky > "${panel_fifo}" &

#### LOOP FIFO

#while :; do
  cat "${panel_fifo}" | $(dirname $0)/i3_lemonbar_parser.sh \
   | lemonbar-xft -p -f "${font}" -f "${iconfont}" -g "${geometry}" -B "${color_back}" -F "${color_fore}" &
#  trap 'trap - TERM; kill 0' INT TERM QUIT EXIT
#done

wait

