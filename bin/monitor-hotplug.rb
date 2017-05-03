#!/usr/bin/env ruby

require 'digest'

IN = 'eDP-1'
SLEEPSECS = 5
PIDFILE = File.join ENV['HOME'], '.monitor-hotplug.pid'
DEBUG = false
PRECMD = ['xrandr --newmode "1920x1080"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync', 'xrandr --addmode eDP-1 "1920x1080"']
POSTCMD = ['nitrogen --restore']
IN_APPEND = ' --mode 1920x1080'
EXT_APPEND = ' --auto --primary'
DRICARD = 'card0'

@dripath = File.join('/sys', %x(udevadm info -q path -n /dev/dri/#{DRICARD}).chomp)
puts "Using sys path: #{@dripath}"

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

def edidchanged?
  @edid ||= []
  curr_edid = []
  puts "checking #{@dripath}/#{DRICARD}-*" if DEBUG
  Dir.glob("#{@dripath}/#{DRICARD}-*").each do |dir|
    puts "checking edid path #{dir}" if DEBUG
    edid_f = File.join(dir, 'edid')
    next unless File.exist?(edid_f)
    curr_edid << Digest::MD5.file(edid_f).to_s
  end
  puts "Stored EDIDs: #{@edid}\nCurrent EDIDs: #{curr_edid}" if DEBUG
  unless @edid.sort == curr_edid.sort
    @edid = curr_edid
    puts 'EDIDs changed' if DEBUG
    return true
  end
  puts 'EDIDs unchanged' if DEBUG
  false
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
    sleep SLEEPSECS
    next unless edidchanged?
    _displays = []
    %x(xrandr).split("\n").each { |l| _displays << l.gsub(/ .*/, '') if l =~ / connected/}
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
end

startup
