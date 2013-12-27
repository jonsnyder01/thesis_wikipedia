#!/usr/bin/env ruby
require 'set'

def dump(obj)
  Marshal.dump(STDOUT, file)
  file.close
end

def load
  obj = Marshal.load(ARGF)
  file.close
  obj
end

index = load
inverted_index = []
i = 0

index.each_with_index do |set, row|
  set.each do |col|
    inverted_index[col] ||= Set.new
    inverted_index[col] << row
  end
  i += 1
  if i % 100000 == 0
    puts i
  end
end

inverted_index.each_with_index do |set, i|
  inverted_index[i] = Set.new if set.nil?
end

dump(inverted_index)

