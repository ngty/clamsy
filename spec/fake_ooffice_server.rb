#!/usr/bin/env ruby
require 'rubygems'
require 'eventmachine'

run_mode, server_port, pid_file = ARGV[0..2]

case run_mode
when 'yes'
  EventMachine::run do
    EventMachine::start_server("0.0.0.0", server_port, Module.new {
      def receive_data (data) ; send_data "printed" ; end
    })
  end
when 'spawn'
  process = IO.popen("#{__FILE__} yes #{server_port}")
  File.open(pid_file,'w') {|fh| fh.write(process.pid) }
  sleep 2
end
