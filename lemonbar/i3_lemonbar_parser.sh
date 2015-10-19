#!/bin/bash
#
# Input parser for i3 bar
# 14 ago 2015 - Electro7

# config
. $(dirname $0)/i3_lemonbar_config

# min init
irc_n_high=0
title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1}"

# parser
while read -r line ; do
  case $line in
    SYS*)
      # 17            Okt 09:50 Sa 0.05 5.71G 125G D 92% 0.0 0.1  down down
      # conky= 
      # 0 = mday, 
      # 1 = month, 
      # 2 = time, 
      # 3 = cpu, 
      # 4 = mem, 
      # 5 = disk /, 
      # 6 = 0/1 power_supply online
      # 7 = batt % 
      # 8-9 = up/down wlan, 
      # 10-11 = up/down eth,
      # 12 = wday
      
      sys_arr=(${line#???})
      # date
      if [ ${res_w} -gt 1024 ]; then
        date="${sys_arr[12]}, ${sys_arr[0]}. ${sys_arr[1]}."
      else
        date="${sys_arr[0]}. ${sys_arr[1]}."
      fi
      date="%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_cal}%{F- T1} ${date}"
      # time
      time="%{F${color_head}}${sep_left}%{F${color_back} B${color_head}} %{T2}${icon_clock} ${sys_arr[2]} %{F- B-}"
      # cpu
      if [ ${sys_arr[3]%.*} -ge ${cpu_alert} ]; then
        cpu_cback=${color_cpu}; cpu_cicon=${color_back}; cpu_cfore=${color_back};
      else
        cpu_cback=${color_sec_b2}; cpu_cicon=${color_icon}; cpu_cfore=${color_fore};
      fi
      cpu="%{F${cpu_cback}}${sep_left}%{F${cpu_cicon} B${cpu_cback}} %{T2}${icon_cpu}%{F${cpu_cfore} T1} ${sys_arr[3]}"
      # mem
      mem="%{F${cpu_cicon}}${sep_l_left} %{T2}${icon_mem}%{F${cpu_cfore} T1} ${sys_arr[4]}"
      # disk /
      diskr="%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_hd}%{F- T1} ${sys_arr[5]}"
      # disk home
      diskh="%{F${color_icon}}${sep_l_left} %{T2}${icon_home}%{F- T1} ${sys_arr[7]}%"
      # bat
      if [ ${sys_arr[7]} -le ${bat_alert} ] && [ ${sys_arr[7]} -ge ${bat_critical} ]; then # warning
        bat_cback=${color_bat}; bat_cicon=${color_back}; bat_cfore=${color_fore}; b_icon=${icon_bate}
      elif [ ${sys_arr[7]} -le ${bat_full} ] && [ ${sys_arr[7]} -gt ${bat_alert} ]; then
        bat_cback=${color_sec_b1}; bat_cicon=${color_icon}; bat_cfore=${color_fore}; b_icon=${icon_bath}
      # Blink background
      elif [ ${sys_arr[7]} -lt ${bat_critical} ]; then
        bat_t_file=/tmp/i3_lemonbar${USER}_battfile
        b_icon=${icon_batc}; bat_cicon=${color_icon}; bat_cfore=${color_fore}
        if [ -e $bat_t_file ]; then
          bat_cback=${color_sec_b1}
          rm $bat_t_file
        else
          bat_cback=${color_bat}
          touch $bat_t_file
        fi
      else
        bat_cback=${color_sec_b1}; bat_cicon=${color_icon}; bat_cfore=${color_fore}; b_icon=${icon_batf}
      fi
      if [ ${sys_arr[6]} == "1" ]; then 
        icon_pwr=${icon_batchg}
      else 
        icon_pwr=${icon_batdischg}
      fi
      bat="%{F${color_sec_b2}}${sep_l_left} %{T2}${icon_bat}%{F${bat_cfore} B${bat_cback}} %{T2}${icon_pwr} ${b_icon} ${sys_arr[7]}%"
      # wlan
      if [ "${sys_arr[8]}" == "down" ]; then
        wland_v="×"; wlanu_v="×";
        wlan_cback=${color_sec_b2}; wlan_cicon=${color_disable}; wlan_cfore=${color_disable};
      else
        wland_v=${sys_arr[8]}K; wlanu_v=${sys_arr[9]}K;
        if [ ${wland_v:0:-3} -gt ${net_alert} ] || [ ${wlanu_v:0:-3} -gt ${net_alert} ]; then
          wlan_cback=${color_net}; wlan_cicon=${color_back}; wlan_cfore=${color_back};
        else
          wlan_cback=${color_sec_b2}; wlan_cicon=${color_icon}; wlan_cfore=${color_fore};
        fi
      fi
      wland="%{F${wlan_cback}}${sep_left}%{F${wlan_cicon} B${wlan_cback}} %{T2}${icon_wireless} ${icon_dl}%{F${wlan_cfore} T1} ${wland_v}"
      wlanu="%{F${wlan_cicon}}${sep_l_left} %{T2}${icon_ul}%{F${wlan_cfore} T1} ${wlanu_v}"
      # eth
      if [ "${sys_arr[10]}" == "down" ]; then
        ethd_v="×"; ethu_v="×";
        eth_cback=${color_sec_b1}; eth_cicon=${color_disable}; eth_cfore=${color_disable};
      else
        ethd_v=${sys_arr[10]}K; ethu_v=${sys_arr[11]}K;
        if [ ${ethd_v:0:-3} -gt ${net_alert} ] || [ ${ethu_v:0:-3} -gt ${net_alert} ]; then
          eth_cback=${color_net}; eth_cicon=${color_back}; eth_cfore=${color_back};
        else
          eth_cback=${color_sec_b1}; eth_cicon=${color_icon}; eth_cfore=${color_fore};
        fi
      fi
      ethd="%{F${eth_cback}}${sep_left}%{F${eth_cicon} B${eth_cback}} %{T2}${icon_wired} ${icon_dl}%{F${eth_cfore} T1} ${ethd_v}"
      ethu="%{F${eth_cicon}}${sep_l_left} %{T2}${icon_ul}%{F${eth_cfore} T1} ${ethu_v}"
      ;;
    VOL*)
      # Volume
      vol="%{F${color_sec_b2}}${sep_left}%{F${color_icon} B${color_sec_b2}} %{T2}${icon_vol}%{F- T1} $(echo ${line%??}|cut -c 4-)"
      ;;
    GMA*)
      # Gmail
      gmail="${line#???}"
      if [ "${gmail}" != "0" ]; then
        mail_cback=${color_mail}; mail_cicon=${color_back}; mail_cfore=${color_back}
      else
        mail_cback=${color_sec_b1}; mail_cicon=${color_icon}; mail_cfore=${color_fore}
      fi
      gmail="%{F${mail_cback}}${sep_left}%{F${mail_cicon} B${mail_cback}} %{T2}${icon_mail}%{F${mail_cfore} T1} ${gmail}"
      ;;
    IRC*)
      # IRC highlight (script irc_warn)
      if [ "${line#???}" != "0" ]; then
        ((irc_n_high++)); irc_high="${line#???}";
        irc_cback=${color_chat}; irc_cicon=${color_back}; irc_cfore=${color_back}
      else
        irc_n_high=0; [ -z "${irc_high}" ] && irc_high="none";
        irc_cback=${color_sec_b2}; irc_cicon=${color_icon}; irc_cfore=${color_fore}
      fi
      irc="%{F${irc_cback}}${sep_left}%{F${irc_cicon} B${irc_cback}} %{T2}${icon_chat}%{F${irc_cfore} T1} ${irc_n_high} %{F${irc_cicon}}${sep_l_left} %{T2}${icon_contact}%{F${irc_cfore} T1} ${irc_high}"
      ;;
    MPD*)
      # Music
      mpd_arr=(${line#???})
      if [ -z "${line#???}" ]; then
        song="none";
      elif [ "${mpd_arr[0]}" == "error:" ]; then
        song="mpd off";
      else
        song="${line#???}";
      fi
      mpd="%{F${color_sec_b2}}${sep_left}%{B${color_sec_b2}}%{F${color_sec_b1}}${sep_left}%{F${color_icon} B${color_sec_b1}} %{T2}${icon_music}%{F${color_fore} T1}  ${song}"
      ;;
    WSP*)
      # I3 Workspaces
      wsp="%{F${color_back} B${color_head}} %{T2}${icon_wsp}%{T1}"
      set -- ${line#???}
      while [ $# -gt 0 ] ; do
        case $1 in
         FOC*)
           wsp="${wsp}%{F${color_head} B${color_wsp}}${sep_right}%{F${color_back} B${color_wsp} T1} ${1#???} %{F${color_wsp} B${color_head}}${sep_right}"
           ;;
         INA*|URG*|ACT*)
           wsp="${wsp}%{F${color_disable} T1} ${1#???} "
           ;;
        esac
        shift
      done
      ;;
    WIN*)
      # window title
      title=$(xprop -id ${line#???} | awk '/_NET_WM_NAME/{$1=$2="";print}' | cut -d'"' -f2)
      #title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2}%{T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} ${title}"
      title="%{F${color_head} B${color_sec_b2}}${sep_right}%{F${color_head} B${color_sec_b2} T2} ${icon_prog} %{F${color_sec_b2} B-}${sep_right}%{F- B- T1} ${title}"
      ;;
  esac

  # And finally, output
  #printf "%s\n" "%{l}${wsp}${title} %{r}${mpd}${stab}${irc}${stab}${gmail}${stab}${cpu}${stab}${mem}${stab}${diskr}${stab}${diskh}${stab}${wland}${stab}${wlanu}${stab}${ethd}${stab}${ethu}${stab}${vol}${stab}${date}${stab}${time}"
  printf "%s\n" "%{l}${wsp}${title} %{r}${mpd}${stab}${irc}${stab}${gmail}${stab}${cpu}${stab}${mem}${stab}${diskr}${stab}${bat}${stab}${wland}${stab}${wlanu}${stab}${ethd}${stab}${ethu}${stab}${vol}${stab}${date}${stab}${time}"
  #printf "%s\n" "%{l}${wsp}${title}"
done
