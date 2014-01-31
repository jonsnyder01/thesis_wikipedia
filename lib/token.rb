
class Token

  attr_reader :value
  def initialize(value)
    @value = value
  end

  def self.create(value)
    case value
    when /^<http:\/\/dbpedia.org\/resource\/Category:(.*)>$/
      Category.new($1)
    when /^<http:\/\/dbpedia.org\/resource\/(.*)>$/
      Resource.new($1)
    when /^<http:\/\/dbpedia.org\/ontology\/(.*)>$/
      Ontology.new($1)
    when /^<http:\/\/www.w3.org\/2004\/02\/skos\/(.*)>$/
      Skos.new($1)
    when /^"(.*)"@en$/
      String.new($1)
    when /^<(.*)>$/
      Url.new($1)
    when ""
      nil
    when /\./
      nil
    else
      Token.new(value)
    end
  end

  def hash
    [self.class, @value].hash
  end

  def eql?(other)
    other.class == self.class && @value == other.value
  end

  def to_s
    "#{self.class.to_s}##{@value[0..42]}"
  end
  
  class Url < Token
  end
  
  class Resource < Url
    def to_s
      @value
    end
  end
  
  class Category < Resource
    def to_s
      @value
    end
  end
  
  class Ontology < Url
  end
  
  class Skos < Url
  end
  
  class String < Token
    def initialize(value)
      super(value.gsub('\"','"'))
    end
    def to_s
      @value
    end
  end
  
end
    
