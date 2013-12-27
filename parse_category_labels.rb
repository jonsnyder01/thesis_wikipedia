#!/usr/bin/env ruby

def dump(obj, name)
  file = File.open(name, 'w')
  Marshal.dump(obj, file)
  file.close
end

category_ids_by_url = {}
category_urls = []
category_labels = []

i = 0
ARGF.each do |line|
  if line[0] == "#"
    next
  end
  line.match(/Category:([^>]*).*"(.*)"@en/) do |match|
    url = match[1]
    label = match[2]
    category_ids_by_url[url] = i
    category_urls << url
    category_labels << label
    i += 1

    if i % 10000 == 0
      puts i
    end
  end
end

dump(category_ids_by_url, "category_ids_by_url")
dump(category_urls, "category_urls")
dump(category_labels, "category_labels")
