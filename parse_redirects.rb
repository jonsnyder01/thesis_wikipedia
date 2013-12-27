#!/usr/bin/env ruby

def dump(obj, name)
  file = File.open(name, 'w')
  Marshal.dump(obj, file)
  file.close
end

redirects = {}

i = 0
ARGF.each do |line|
  if line[0] == "#"
    next
  end
  line.match(/resource\/([^>]*)>.*resource\/([^>]*)>/) do |match|
    redirects[match[1]] = match[2]
    i += 1
    if i % 100000 == 0
      puts i
    end
  end
end

dump(redirects, "redirects")
