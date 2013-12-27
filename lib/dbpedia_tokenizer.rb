require 'token'

class DbpediaTokenizer

  def initialize(input)
    @input = input
  end

  
  def each_line
    @input.each do |line|
      tokens = line.scan(/ *(?:<[^>]*>|"(?:\\"|[^"])*"@..|\.|[^<"@]+) */).map do |match|
        Token.create(match.strip)
      end
      yield tokens.compact
    end
  end

end
