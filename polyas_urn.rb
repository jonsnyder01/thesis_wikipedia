
def putBall(color, last_in_box=false)
  ending = last_in_box ? "%" : "";
  puts "\\tikz\\draw[fill=#{color}] (0,0) circle (1ex);#{ending}"
end

alpha = ARGV.shift.to_i
examples = ARGV.shift.to_i

puts "\\begin{spacing}{1.5}"
puts "\\begin{centering}"
examples.times do |i|
  urn = []
  alpha.times { urn << "red" }
  alpha.times { urn << "blue" }
  alpha.times { urn << "yellow" }

  puts "\\fbox {%"
  urn.each_with_index do |color, i|
    putBall(color, (i == urn.size - 1))
  end
  puts "}\\\\"

  20.times do
    color = urn.sample
    urn << color
    putBall(color)
  end

  puts "\\\\"

  20.times do
    color = urn.sample
    urn << color
    putBall(color)
  end
  puts "\\\\"
  if i < examples - 1
    puts "\\bigskip"
  end
end
puts "\\end{centering}"
puts "\\end{spacing}"

