# Helge's i3 configuration

My personal configuration for the [i3](https://i3wm.org/) Window Manager.

## Setup

This guide assumes you have i3 installed, are logged in and running i3 with it's 
default configuration in an Xfce4 session under X11

### Required additional packages
*EL/Fedora package names*

#### i3
- nitrogen
- brighnessctl
- xfsettingsd
- blueman-applet
- compton
- amixer
- playerctl
- gnome-keyring-daemon
- xrandr

#### Desktop applications referenced
- roxterm
- google-chrome
- thunar

#### i3blocks
- sysstat

### Step by step

1. Install additional packages
2. Clone this repository to `~/.i3` or `~./.config/i3`
3. Build the [i3blocks](https://github.com/vivien/i3blocks) binary
4. Copy `systemd/monitor-hotplug.service` to `~/.config/systemd` and enable the service
`systemctl --user enable monitor-hotplug.service`
5. Install `fontawesome-webfont.ttf` from `fonts/`

