require 'stanford-core-nlp'
require 'sentence_annotations'

path = File.join( File.dirname(File.dirname(__FILE__)),'vendor', 'stanford-core-nlp-full')
StanfordCoreNLP.jar_path = path + '/'
StanfordCoreNLP.model_path = path + '/'
StanfordCoreNLP.log_file = File.join( path, 'log.txt')

class StanfordSentenceAnnotator

  def initialize(pipeline=nil)
    @pipeline_config = pipeline || [:tokenize, :ssplit, :pos]
  end

  def parse(id_text_pairs)
    Enumerator.new do |y|
      id_text_pairs.each do |id, text|
        y << [id, parse_sentence(text)]
      end
    end
  end

  private

  def parse_sentence(text)
    sentences = []
    pipeline
    annotation = StanfordCoreNLP::Annotation.new(text)
    pipeline.annotate(annotation)
    annotation.get(:sentences).each do |sentence|
      tokens = []
      pos = []
      sentence.get(:tokens).each do |token|
        value = token.get(:value).to_s.downcase
        next if value =~ /[^-a-z0-9']/
        next if value =~ /^[^a-z0-9]*$/
        next if value == '-rrb-'
        next if value == '-lrb-'
        tokens << value
        pos << token.get(:part_of_speech).to_s
      end
      sentences << SentenceAnnotations.new(sentence.get(:text).to_s, tokens, pos)
    end
    sentences
  end

  def pipeline
    @pipeline ||= StanfordCoreNLP.load(*@pipeline_config)
  end
  
end
