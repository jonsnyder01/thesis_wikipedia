
class DbpediaParser 
  def initialize(tokenizer, tuple_logger, status_file)
    @tokenizer = tokenizer
    @tuple_logger = tuple_logger
    @status_file = status_file
  end

  def scan(pattern, &block)
    i = 0
    @tokenizer.each_line do |tuple|
      i += 1
      prototype = pairwise_match(pattern,tuple)
      if !prototype.include?(nil)
        begin
          yield tuple
        rescue => e
          @tuple_logger.log(e.message, tuple)
        end
      else
        @tuple_logger.log(prototype, tuple)
      end
      if i % 100000 == 0
        @status_file.puts i
      end
    end
    @tuple_logger.close
  end

  private

  def pairwise_match(pattern, tuple)
    prototype = pattern.zip(tuple).map do |pattern_item, tuple_item|
      if pattern_item.is_a? Class
        if tuple_item.is_a? pattern_item
          pattern_item
        else
          nil
        end
      else
        if tuple_item.eql? pattern_item
          pattern_item
        else
          nil
        end
      end
    end
  end
end
