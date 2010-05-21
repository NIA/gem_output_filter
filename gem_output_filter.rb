#!/usr/bin/env ruby

@doc_started = false
@newline_put = true
@unpacking = false
@gemspec = nil
@doc = nil

def new_line(text, newline_after = false)
  puts unless @newline_put
  print text
  puts if newline_after
  @newline_put = newline_after
end

def put_same(line, newline_after = false)
  new_line line, newline_after
  @unpacking = false
end

def put_char(char, unpacking = false)
  print char
  @newline_put = false
  @unpacking = unpacking
end

new_line "Updating gem list"

while (line = gets) do
  line.rstrip!
  case line
  when /^GET http:.+\/([^\/]+)\.gemspec\.rz/
    new_line("Fetching gemspec for #$1") if @gemspec != $1
    @gemspec = $1
    put_char '.'
  when /^GET http:.+/
    put_char '.'
  when /^connection reset/
    put_char ','
  when /^Installing (RDoc|ri)/
    # documentation messages
    new_line ("Installing #$1") if @doc != $1
    @doc = $1
    put_char '.'
  when /^\/usr\/lib\/ruby\/gems/
    unless @unpacking
      new_line "Unpacking gem"
    end
    put_char('.', true)
  when /^\d+ gem/
    puts
    put_same line
    puts
  when /^Successfully/
    put_same line, true
    puts
  when /^\//, /(?:make|gcc|Makefile)/
    #ignore build messages
  when /^\s*$/
    #ignore empty
  when /^\d{3} [A-Z]/
    #ignore http status codes
  when /Could not find main page README.rdoc/
    #ignre rdoc errors
  else
    # installation process messages
    # cistom gems messages
    put_same line
  end
end

puts

