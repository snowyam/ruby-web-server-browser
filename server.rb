require 'socket'
require 'json'

server = TCPServer.open(2000)
loop do
  session = server.accept

  request = session.gets
  STDERR.puts request

  request_parse = request.split(" ")
  verb = request_parse[0]
  path = request_parse[1]

  time = Time.now.ctime

  if verb == "GET" && File.exist?(path)
    content = File.open(path, 'r')

    session.print "HTTP/1.0 200 OK\r\n"
    session.print "Date: #{time}\r\n"
    session.print "Content-Type: text/html\r\n"
    session.print "Content-Length: #{content.size}\r\n"
    session.print "\r\n"

    session.print content.read
  elsif verb == "POST"
    puts session.gets
    puts session.gets
    post_parse = session.gets.chomp
    STDERR.puts post_parse

    params = {}
    params = JSON.parse(post_parse)
    replace_yield = ""
    params.values.each do |value|
      value.each_pair do |key, val|
        replace_yield += "<li>#{key}: #{val}</li>"
      end
    end

    content = File.read(path)
    content.gsub!("<%= yield %>", replace_yield)
    
    session.print "HTTP/1.0 200 OK\r\n"
    session.print "Date: #{time}\r\n"
    session.print "Content-Type: text/html\r\n"
    session.print "Content-Length: #{content.size}\r\n"
    session.print "\r\n"

    session.print content
  else
    if File.exist?(path) != true
      error_msg = "File not found.\n"
    else
      error_msg = "Invalid verb request!\n"
    end

    session.print "HTTP/1.0 404 Not found\r\n"
    session.print "Date: #{time}\r\n"
    session.print "Content-Type: text/plain\r\n"
    session.print "Content-Length: #{error_msg.size}\r\n"
    session.print "\r\n"

    session.puts "#{error_msg}"
  end

  session.close
end