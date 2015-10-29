require 'command'
require 'sentence_annotations'
require 'json'
require 'i18n'
require 'parallel'

class NltkSentenceAnnotator

  NLTK = "python ./vendor/nltk/sentence_split.py"

  def initialize(temp_folder)
    @temp_folder = temp_folder
  end

  def parse(id_text_pairs)
    Dir.mkdir(@temp_folder) unless Dir.exist?(@temp_folder)

    slice_index = 0
    filenames = id_text_pairs.each_slice(5000).map do |id_text_pairs_batch|
      filename = "#{@temp_folder}/text#{slice_index}"
      File.open(filename,"w") do |f|
        id_text_pairs_batch.each do |id, text|
          f.puts(JSON.generate({id: id, text: text}))
        end
      end
      slice_index += 1
      filename
    end

    batches = Parallel.map(filenames) do |filename|
      results = []
      Command.run("#{NLTK} #{filename}") do |line|
        next if line.nil?
        parsed = JSON.parse(line)
        annotations = parsed["sentences"].map do |sentence|
          tokens = I18n.transliterate(sentence["tokens"].join(" ")).downcase.sub("-"," ").sub("?"," ").split(" ").select do |token|
            token.match(/[A-Za-z0-9]/)
          end
          SentenceAnnotations.new(sentence["raw"].strip, tokens, nil)
        end
        results << [parsed["id"], annotations]
      end
      results
    end
    Enumerator.new do |y|
      batches.each do |batch|
        batch.each do |parsed|
          y << parsed
        end
      end
    end
  end

  def tokenize(id_text_pairs)
    Enumerator.new do |y|
      parse(id_text_pairs).each do |id, annotations|
        tokens = []
        annotations.each do |annotation|
          tokens += annotation.tokens
        end
        y << [id, tokens]
      end
    end
  end
end
