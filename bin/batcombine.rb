#!/usr/bin/env ruby
# Combine batteries to one uvent file for i3bar
#

require 'fileutils'

UVEVENTPATH = '/sys/class/power_supply/BAT*'
WAIT_TIME = 5
OUTPUT_FILE = "#{ENV['HOME']}/.uevent"
PIDFILE="#{ENV['HOME']}/.batcombine.pid"

def to_something(str)
  duck = (Integer(str) rescue Float(str) rescue nil) 
  duck.nil? ? str : duck  
end

def write_output(content)
  result = ''
  content.each do |k,v|
    result << "#{k}=#{v}\n"
  end
  File.open(@output_file, 'w') { |file| file.write(result) }
end

def startup
  File.write PIDFILE, @pid
  Process.detach @pid
  puts "Forked process PID #{@pid}"
end

def shutdown
  File.delete @output_file if File.exist? @output_file
  File.delete(PIDFILE)
  exit 0
end

def combinebatts(result, nextbatt)
  result.merge!(nextbatt) do |k, o, n|
    case nextbatt[k]
      when Fixnum then o + n
      else n
    end
  end
  result[:POWER_SUPPLY_PRESENT] = 1 if result[:POWER_SUPPLY_PRESENT] >= 1
  result[:POWER_SUPPLY_CAPACITY] = (result[:POWER_SUPPLY_ENERGY_NOW] * 100 / result[:POWER_SUPPLY_ENERGY_FULL]).to_i
  result[:POWER_SUPPLY_VOLTAGE_MIN_DESIGN] = (result[:POWER_SUPPLY_VOLTAGE_MIN_DESIGN] / 2).to_i
  result[:POWER_SUPPLY_POWER_NOW] = (result[:POWER_SUPPLY_POWER_NOW] / 2).to_i
end

def format_uevent(uevent)
  result = {}
  uevent.split("\n").each do |line|
    pair = line.split('=')
    result[pair[0].to_sym] = to_something(pair[1].strip)
  end
  result
end

@output_file = ARGV[0] ||= OUTPUT_FILE

@pid = fork do

  Signal.trap('INT') do
    shutdown
  end
  Signal.trap('TERM') do
    shutdown
  end

  batts = Dir[UVEVENTPATH]

  loop do
    uevent_data = []
    combined = {}

    batts.each do |batt|
      uevent_data << format_uevent(File.read("#{batt}/uevent")) if File.exist? "#{batt}/uevent"
    end

    uevent_data.each do |current|
      combinebatts(combined, current)
    end

    write_output combined

    sleep WAIT_TIME
  end
end

startup
