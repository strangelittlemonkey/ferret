#!/usr/bin/env ruby

# command line ranged port scanner
# design to print result to a file on screen or both
# even scan time for those that are curious

require 'socket'
require 'etc'
require 'timeout'
require 'optparse'
require 'benchmark'

hostname = nil
closedArr = Array.new
openArr = Array.new
hungArr = Array.new
arr = Array.new
testPorts = Array.new

# default values for the hash should help

options = { :verbose => false, :benchmark => false,
           :output => false, :debug => false }

# options to check for
OptionParser.new do |opts|
  opts.banner = 'Usage: ferret.rb [options] [ports]'
  
  opts.on( '-v', '--verbose' ) do |v|
    options[:verbose] = v
  end
  
  opts.on( '-d', '--debug' ) do |d|
    options[:debug] = d
  end
  
  opts.on( '-h', '--help' ) do |h|
    puts( opts.banner )
    exit
  end
  
  opts.on( '-b', '--benchmark' ) do |b|
    options[:benchmark] = b
  end
  
  opts.on( '-o', '--output' ) do |o|
    options[:output] = o
  end
  
  opts.on( '-l', '--list' ) do |l|
    arr = ARGV[1].split(',')
    hostname = ARGV[0]
    arr.each do |rangnum|
  
# thread for each port felt it would be good since there's real time invovled
# otherwise current range would take 8.41mins if they all hung
      testPorts << Thread.new do
      client = nil
      puts( %Q/Checking port #{rangnum}.../ ) if options[:verbose]
      Thread.pass
         
      begin
# client has five seconds to get a hit
        Timeout::timeout(5) { client = TCPSocket.open( hostname, rangnum ) }
      rescue Timeout::Error
# if it has such a hang up, it ends up here
        hungArr << rangnum
        puts( %Q/Port #{rangnum} timed out./ ) if options[:verbose]
      rescue Errno::ECONNREFUSED
# closed ports go here
        closedArr << rangnum
        puts( %Q/Port #{rangnum} closed./ ) if options[:verbose]
      else
# otherwise they're fine added to an array and closed
# note ensure client.close would be an error itself
# the erro never open a port to begin with
        openArr << rangnum
        puts( %Q/Port #{rangnum} is open./ ) if options[:verbose]
        client.close
      end
      
    end#.join
# joining here works, crashes on port 80 which is said to be open
#  letter.next!
    end # arr loop

  end
  
  opts.on( '-r', '--range' ) do
#     puts( ARGV.inspect )
    
    arr = ARGV[1].split('-')
    hostname = ARGV[0]
    (arr[0]..arr[1]).each do |rangnum|
  
# thread for each port felt it would be good since there's real time invovled
# otherwise current range would take 8.41mins if they all hung
      testPorts << Thread.new do
      client = nil
      puts( %Q/Checking port #{rangnum}.../ ) if options[:verbose]
      Thread.pass
         
      begin
# client has five seconds to get a hit
        Timeout::timeout(5) { client = TCPSocket.open( hostname, rangnum ) }
      rescue Timeout::Error
# if it has such a hang up, it ends up here
        hungArr << rangnum
        puts( %Q/Port #{rangnum} timed out./ ) if options[:verbose]
      rescue Errno::ECONNREFUSED
# closed ports go here
        closedArr << rangnum
        puts( %Q/Port #{rangnum} closed./ ) if options[:verbose]
      else
# otherwise they're fine added to an array and closed
# note ensure client.close would be an error itself
# the erro never open a port to begin with
        openArr << rangnum
        puts( %Q/Port #{rangnum} is open./ ) if options[:verbose]
        client.close
      end
      
    end#.join
# joining here works, crashes on port 80 which is said to be open
#  letter.next!
    end 
  end
  
end.parse!

# current collection of debugging information
if ( options[:debug] ) then
puts( 'Options are equal to.')
p( options.inspect )
puts( 'ARGV contains: ' )
p( ARGV.inspect )
puts( 'Arr contains: ' )
p( arr.inspect )
puts( 'HostName: ' )
p( hostname )
end

totaltime = Benchmark.measure {

# run test here in an attempt to get them to run at the same time
# here all ports time out...???
# quick scan but doesn't seem to work 'correctly'
# p( testPorts.inspect )
testPorts.each { |thread| thread.join }

# write to the file with list
location = nil

if ( RUBY_PLATFORM =~ /linux/ ) then
  location = %Q\/home/#{Etc.getlogin}/portcheck.txt\
else
# need to find a way to get windows user info
  location = %q/C:\Users\Guest\My Documents\portcheck.txt/
end

# sorting the collected ports
hung = hungArr.join(', ').gsub(/((\w+\,\s){4}\w+\,)(\s)/, ('\1'+10.chr))
closed = closedArr.join(', ').gsub(/((\w+\,\s){4}\w+\,)(\s)/, ('\1'+10.chr))
opened = openArr.join(', ').gsub(/((\w+\,\s){4}\w+\,)(\s)/, ('\1'+10.chr))


if ( options[:output] ) then
  
  File::open( location, 'w' ) do |file|
    file.puts( %Q/These ports are open: #{opened}/ )
    file.puts( %Q/These ports are closed: #{closed}/ )
    file.puts( %Q/These ports timed out: #{hung}/ )
  end

end
}

# add bench mark time only if asked for in options
if ( options[:benchmark] ) then
  puts( totaltime )
end