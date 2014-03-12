require 'nokogiri'
require 'zlib'
require 'command'
require 'mallet_topic'

class MalletCommand
  
  TOKEN_REGEX = '[^\s]+'
  MALLET = '../thesis/ir-walltriage/vendor/mallet/bin/mallet'
  
  def initialize(article_gateway, stopwords, marshal_helper, topic_gateway, options)
    @article_gateway = article_gateway
    @stopwords = stopwords
    @marshal_helper = marshal_helper
    @topic_gateway = topic_gateway
    @options = options
  end

  def run(options={})

    @marshal_helper.clear
    xml_topic_phrase_report = nil
    output_state = nil
    @marshal_helper.write("mallet.log") do |mallet_log|
    
      mallet_input_filename = @marshal_helper.filename("input.txt")
      mallet_file = @marshal_helper.filename("input.mallet")
      output_doc_topics = @marshal_helper.filename("output_doc_topics.txt")
      xml_topic_phrase_report = @marshal_helper.filename("xml_topic_phrase_report.xml")
      output_state = @marshal_helper.filename("output_state.gz")

      @marshal_helper.write("input.txt") do |input|
        @article_gateway.each do |article|
          tokens = (article.sentence_annotations || []).map { |sentence_annotation| sentence_annotation.tokens }.flatten.reject { |token| @stopwords.include?(token) }
          input.puts(article.id.to_s + " en " + tokens.join(' '))
        end
      end
      
      Command.run "#{MALLET} import-file --keep-sequence --input #{mallet_input_filename} --output #{mallet_file} --token-regex '#{TOKEN_REGEX}'", mallet_log
      Command.run "#{MALLET} train-topics --input #{mallet_file} #{mallet_options} --output-doc-topics #{output_doc_topics} --xml-topic-phrase-report #{xml_topic_phrase_report} --output-state #{output_state}", mallet_log
    end
    
    import_xml_topic_phrase_report(xml_topic_phrase_report)
    output_word_topic_mappings(output_state)
  end

private

  def mallet_options
    num_topics = @options[:topics] || 10
    num_iterations = @options[:iterations] || 2000
    optimize_burn_in = (num_iterations * 0.1).to_i
    alpha = 50
    use_symetric_burn_in = false
    
    "--num-topics #{num_topics} --num-iterations #{num_iterations} --optimize-interval 20 --optimize-burn-in #{optimize_burn_in} --alpha #{alpha} --use-symmetric-alpha #{use_symetric_burn_in ? 'TRUE' : 'FALSE'} --show-topics-interval 500 --num-top-words 20"
  end

  def import_xml_topic_phrase_report(filename)
    File.open(filename, 'r') do |file|
      doc = Nokogiri::XML( file)

      doc.xpath('//topics/topic').each do |topic|
        top = []
        topic.children.each do |topic_word|
          if !topic_word.text?
            top << MalletTopic::Top.new(topic_word['count'],topic_word.content.strip)
          end
        end
        @topic_gateway.create(MalletTopic.new(topic['alpha'],topic['totalTokens'], topic['titles'], top))
      end
    end
  end

  def read_output( filename)
    
    Zlib::GzipReader.open( filename) do |gz|
      gz.each_line do |line|
        case line
        when /^#/
          next
        else
          row = line.split(" ")
          yield row[4], row[5].to_i
        end
      end
    end
  end

  def output_word_topic_mappings(output_state_filename)
    output_mappings_enum = enum_for(:read_output, output_state_filename)
    @article_gateway.each do |article|
      (article.sentence_annotations || []).each do |sentence_annotation|
        sentence_topics = []
        sentence_annotation.tokens.each do |token|
          if !@stopwords.include?(token)
            mapped_word, topic = output_mappings_enum.next
            raise "Not Sync'ed" if mapped_word != token
            sentence_topics << topic
          else
            sentence_topics << nil
          end
        end
        sentence_annotation.topics = sentence_topics
      end
    end
  end
  
end
