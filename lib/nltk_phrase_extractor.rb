require 'command'
require 'chunked_phrase'
require 'json'
require 'i18n'
require 'parallel'

class NltkPhraseExtractor

  NLTK = "python ./vendor/nltk/title_chunk.py"

  def initialize(temp_folder)
    @temp_folder = temp_folder
  end

  def run(id_annotation_pairs)
    Dir.mkdir(@temp_folder) unless Dir.exist?(@temp_folder)

    slice_index = 0
    filenames = id_annotation_pairs.each_slice(10000).map do |id_annotation_pairs_batch|
      filename = "#{@temp_folder}/text#{slice_index}"
      File.open(filename,"w") do |f|
        id_annotation_pairs_batch.each do |id, annotations|
          f.puts(JSON.generate({id: id, sentences: annotations.map {|annotation| annotation.words}}))
        end
      end
      slice_index += 1
      filename
    end

    batches = Parallel.map(filenames, in_processes: 4) do |filename|
      results = []
      Command.run("#{NLTK} #{filename}") do |line|
        next if line.nil?
        parsed = JSON.parse(line)
        if parsed["id"] % 100 == 0
          puts parsed["id"]
        end
        phrases = parsed["phrases"].map do |phrase|
          tokens = []
          token_mapping = []
          phrase.each_with_index do |token, index|
            I18n.transliterate(token).downcase.sub("-"," ").sub("?"," ").split(" ").each do |clean_token|
              if clean_token.match(/[A-Za-z0-9]/)
                 tokens << clean_token
                 token_mapping << index
              end
            end
          end
          ChunkedPhrase.new(phrase, tokens, token_mapping)
        end
        results << [parsed["id"], phrases]
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
