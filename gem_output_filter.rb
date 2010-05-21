#!/usr/bin/env ruby

@doc_started = false
@newline_put = true
@unpacking = false
@gemspec = nil
@doc = nil
@building = false

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

$stdout.flush
while line = gets do
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
  when /^Installing gem/
    puts
    put_same line
    @building = false
  when /^Building native extensions/
    unless @building
      put_same line
    else
      put_char '.'
    end
    @building = true
  when /^\//, /(?:make|gcc|Makefile)/
    # build messages
    put_char '.'
  when /^\(in \//
    #make messages (in /some/directory)
    put_char '.'
  when /^\s*$/
    #ignore empty
  when /^\d{3} [A-Z]/
    #ignore http status codes
  when /Could not find main page README.rdoc/
    #ignre rdoc errors
  when /Updating installed gems/
    #ignore gem update message because it intercepts output
  else
    # installation process messages
    # cistom gems messages
    put_same line
  end
  $stdout.flush
end

puts

