#!/usr/bin/env ruby

puts "Updating gem list"

doc_started = false
newline_put = true
unpacking = false

while (line = gets) do
  case line
  when /^GET http:/
    print '.'
    newline_put = false
    unpacking = false
  when /^connection reset/
    print ','
    newline_put = false
    unpacking = false
  when /^(?:Installing gem|Succesfully|Downloading|Using local)/
    # process messages
    puts unless newline_put
    puts line
    newline_put = true
    unpacking = false
  when /^[* ]/
    # gems messages
    puts unless newline_put
    puts line
    newline_put = true
    unpacking = false
  when /^\/usr\/lib\/ruby\/gems/
    unless unpacking
      puts unless newline_put
      puts "Unpacking gem"
    end
    print '>'
    newline_put = false
    unpacking = true
  when /^Installing (RDoc|ri)/
    puts unless newline_put
    puts line
    newline_put = true
    unpacking = false
  end
end

puts
