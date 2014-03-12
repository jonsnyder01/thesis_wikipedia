require 'command'
require 'sentence_annotations'

class ClearnlpSentenceAnnotator

  CLEARNLP = "./vendor/clearnlp/clearnlp"

  def initialize(temp_folder)
    @temp_folder = temp_folder
  end

  def parse(id_text_pairs)
    id_text_pairs = id_text_pairs.to_a
    id_text_pairs.each do |id, text|
      puts text
      File.open("#{@temp_folder}/#{id}text","w") { |f| f.puts text }
    end
    Command.run("#{CLEARNLP} #{@temp_folder}")
    Enumerator.new do |y|
      id_text_pairs.each do |id, text|
        sentences = []
        tokens = []
        raw_start = 0
        raw_end = 0
        File.readlines("#{@temp_folder}/#{id}text.tok").each do |word|

          word = word.strip
          puts word
          if word == ""
            sentences << SentenceAnnotations.new(text[raw_start..raw_end].strip, tokens, nil) if !tokens.empty?
            tokens = []
            raw_start = raw_end + 1
          else
            if word.match(/[A-Za-z0-9]/)
              tokens << word.downcase
            end
            raw_end = text.index(word, raw_end) + word.size - 1
          end
        end
        sentences << SentenceAnnotations.new(text[raw_start..raw_end].strip, tokens, nil) if !tokens.empty?
        y << [id, sentences]
      end
    end
  end
end