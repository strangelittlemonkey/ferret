#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'socket'

# This hash will hold all of the options
# parsed from the command-line by
# OptionParser.
options = {}

optparse = OptionParser.new do |opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner = "Usage: main.rb [options] host1 host2"

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end

  # Define the options and what they do
  options[:verbose] = false
  opts.on( '-v', '--verbose', 'Output more information' ) do
    options[:verbose] = true
  end
end

optparse.parse!

commonports = [ #'22',
                '23',
                '25',
                '80',
              ]
#def scan(ports)
  begin
  currentport = nil
    commonports.each do |port|
      currentport = port
      target = TCPSocket.new 'localhost', port
      while line = target.gets
        puts line
      end

      target.close
    end
    rescue Errno::ECONNREFUSED #Port is closed or packets are being rejected
      puts 'port ' << currentport << ' is closed'
      next
    end
#  end

#scan
