#!/usr/bin/env ruby
IN = 'eDP-1'
SLEEPSECS = 5
PIDFILE = File.join ENV['HOME'], '.monitor-hotplug.pid'
DEBUG = false
PRECMD = ['xrandr --newmode "1920x1080"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync', 'xrandr --addmode eDP-1 "1920x1080"']
POSTCMD = ['nitrogen --restore']
IN_APPEND = ' --mode 1920x1080'
EXT_APPEND = ' --auto --primary'

def shutdown
  File.delete(PIDFILE) if File.exist? PIDFILE
  exit 0
end

def startup
  exit! if File.exist? PIDFILE
  File.write PIDFILE, @pid
  Process.detach @pid unless DEBUG
  puts "Forked process PID #{@pid}"
end

def execute(cmd)
  DEBUG ? (puts cmd) : (%x(#{cmd}))
end

PRECMD.each do |cmd|
  execute cmd
  sleep 0.5
end

@pid = fork do
  
  Signal.trap('INT') do
    shutdown
  end
  Signal.trap('TERM') do
    shutdown
  end

  loop do
    puts 'Running loop' if DEBUG
    @displays ||= []
    _displays = []
    %x(xrandr).split("\n").each { |l| _displays << l.gsub(/ .*/, '') if l =~ / connected/}
    unless @displays.sort == _displays.sort
      @displays = _displays
      external = (_displays - [IN]).first
      if external # external monitor
        @external = external
        xrandr = "xrandr --output #{IN} --off --output #{@external}#{EXT_APPEND}"
      else
        xrandr = "xrandr --output #{@external||= 'UDEF'} --off --output #{IN} --primary#{IN_APPEND}"
      end
      execute xrandr
      POSTCMD.each do |cmd|
        execute cmd
      end
    end
    sleep SLEEPSECS
  end
end

startup
