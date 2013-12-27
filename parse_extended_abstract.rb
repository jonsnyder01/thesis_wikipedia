#!/usr/bin/env ruby

def dump(obj, name)
  file = File.open(name, 'w')
  Marshal.dump(obj, file)
  file.close
end

article_ids_by_url = {}
article_urls = []
article_abstracts = []

i = 0
ARGF.each do |line|
  if line[0] == "#"
    next
  end
  line.match(/resource\/([^>]*).* "(.*)"@en/) do |match|
    url = match[1]
    abstract = match[2].gsub('\"', '"')
    article_ids_by_url[url] = i
    article_urls << url
    article_abstracts << abstract
    i += 1
    if i % 100000 == 0
      puts i
    end
  end
end

dump(article_ids_by_url, "article_ids_by_url")
dump(article_urls, "article_urls")
dump(article_abstracts, "article_abstracts")
