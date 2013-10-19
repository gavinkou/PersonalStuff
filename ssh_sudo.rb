#!/usr/bin/ruby
require 'net/ssh'
password=""  #the password
username='ggou'
host=ARGV[0]
cmd=ARGV[1..ARGV.length-1].join(" ")

begin
#Net::SSH.start(host, username, :password=> password, :verbose => :debug ) do | session |
Net::SSH.start(host, username, :password=> password, :timeout=>3 ) do | session |
    retry_count=0

    session.open_channel do | channel|
      channel.request_pty
      channel.exec("sudo #{cmd}") do | ch, success|
      #channel.exec("#{cmd}") do | ch, success|
      #channel.exec("echo 'robert:$1$6GMZgbZQ$Ri.lOT85EtM2OUnD2vgYD.' | sudo /usr/sbin/chpasswd -e") do | ch, success|
        abort "could not execute command" unless success
        channel.on_data do | ch, data |
          if data =~ /password/i
            retry_count+=1
            channel.send_data password+"\n"
          else
            puts data
          end
        end
        channel.on_extended_data do |ch, type, data|
          if data =~ /Password/
            retry_count+=1
            channel.send_data password+"\n"
          end
        end
        channel.do_failure() do |ch, f|

        end
        channel.on_close do |ch|
          puts "Error for #{host}" if retry_count > 1
        end
    end
  end


end


rescue  Exception
  $stderr.print "Error: #{$!} on #{host}\n"
end

