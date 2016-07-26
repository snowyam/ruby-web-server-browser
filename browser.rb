require 'socket'
require 'json'

host = 'localhost'
port = 2000
get_path = "index.html"
post_path = "thanks.html"

socket = TCPSocket.open(host, port)

puts "What type of request to send? Enter 'get' or 'post':"
user_input = gets.chomp
until user_input == "get" || user_input == "post"
  puts "Error: Not a verb request. Please enter again: "
  user_input = gets.chomp
end

if user_input == "get"
  request = "GET #{get_path} HTTP/1.0\r\n\r\n"
else
  puts "Enter a name to accompany the POST request: "
  name = gets.chomp
  puts "Enter an email to accompany the request: "
  email = gets.chomp

  data = { request: { name: name.to_s, email: email.to_s} }.to_json
  puts "JSON string: #{data}\n\n"
  request = "POST #{post_path} HTTP/1.0\r\n" +
            "Content-Type: text/html\r\n" +
            "Content-Length: #{data.size}\r\n" +
            "#{data}\r\n" +
            "\r\n"
end

socket.print(request)
response = socket.read
headers, body = response.split("\r\n\r\n", 2)
print "#{headers}\r\n\n"
print "#{body}\n"