require 'json'

class SimpleArticleGateway

  def initialize(titles,texts)
    @size = [titles.size,texts.size].min
    @titles = titles
    @texts = texts
  end

  def create(title, text)
    @titles << title
    @texts << text
    @size += 1
  end    
  
  def subset(other, article_ids)
    article_ids.each do |id|
      other.create(@titles[id], @texts[id])
    end
  end

  def write_pipeline_file(file)
    (0..@size-1).each do |id|
      title = @titles[id]
      text = @texts[id]
      next unless title && text
      file.puts JSON.dump({id: id, title: title, text: text})
    end
  end
  
end
