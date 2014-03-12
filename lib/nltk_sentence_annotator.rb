require 'command'
require 'sentence_annotations'
require 'json'

class NltkSentenceAnnotator

  NLTK = "python ./vendor/nltk/sentence_split.py"

  def initialize(temp_folder)
    @temp_folder = temp_folder
  end

  def parse(id_text_pairs)
    Enumerator.new do |y|
      id_text_pairs.each_slice(1000) do |id_text_pairs_batch|
        File.open("#{@temp_folder}/text","w") do |f|
          id_text_pairs_batch.each do |id, text|
            f.puts(JSON.generate({id: id, text: text}))
          end
        end
        Command.run("#{NLTK} #{@temp_folder}/text") do |line|
          parsed = JSON.parse(line)
          annotations = parsed["sentences"].map do |sentence|
            tokens = sentence["tokens"].select do |token|
              token.match(/[A-Za-z0-9]/)
            end.map { |token| token.downcase }
            SentenceAnnotations.new(sentence["raw"].strip, tokens, nil)
          end
          y << [parsed["id"], annotations]
        end
      end
    end
  end
end