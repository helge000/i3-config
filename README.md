# Helge's i3 configuration

My personal configuration for the [i3](https://i3wm.org/) Window Manager.

![Desktop](desktop.png)

## Setup

This guide assumes you have i3 installed, are logged in and running i3 with it's 
default configuration [in an Xfce4 session](https://feeblenerd.blogspot.com/2015/11/pretty-i3-with-xfce.html) under X11

### Required additional packages
*EL/Fedora package names*

#### i3
- nitrogen
- [brighnessctl](http://rpmfind.net/linux/fedora/linux/releases/28/Everything/x86_64/os/Packages/b/brightnessctl-0.3-2.fc28.x86_64.rpm)
- xfsettingsd
- blueberry
- [compton](https://copr.fedorainfracloud.org/coprs/mrbloups/compton/)
- alsa-utils
- [playerctl](https://github.com/acrisci/playerctl)
- gnome-keyring-daemon
- xrandr
- xnote
- parcellite
- nm-applet

#### Desktop applications referenced
- roxterm
- google-chrome
- thunar
- Thunderbird
- Zeal


#### i3blocks
- sysstat

### Step by step

1. Install additional packages
2. Clone this repository to `~/.i3` or `~./.config/i3`
3. Build the [i3blocks](https://github.com/vivien/i3blocks) binary
4. Copy `systemd/monitor-hotplug.service` to `~/.config/systemd` and enable the service
`systemctl --user enable monitor-hotplug.service`
5. Install `fontawesome-webfont.ttf` from `fonts/`
6. Check [dmenu-extended](https://github.com/MarkHedleyJones/dmenu-extended) dependencies

