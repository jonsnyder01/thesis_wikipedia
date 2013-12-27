#!/usr/bin/env ruby
ENV['BUNDLE_GEMFILE'] = File.join(File.dirname(__FILE__), 'Gemfile')
require 'rubygems'
require 'bundler/setup'
require 'bitarray'


def dump(obj, name)
  file = File.open(name, 'w')
  Marshal.dump(obj, file)
  file.close
end

def load(name)
  file = File.open(name, 'r')
  obj = Marshal.load(file)
  file.close
  obj
end

article_ids_by_url = load('article_ids_by_url')
article_count = article_ids_by_url.size
puts "Articles: #{article_count}"

category_ids_by_url = load('category_ids_by_url')
category_count = category_ids_by_url.size
puts "Categories: #{category_count}"

redirects = load('redirects')
puts "Redirects: #{redirects.size}"

categories = Array.new(category_count) { Set.new() }

i = 0
found = 0
missing = 0
found_redirect = 0
ARGF.each do |line|
  if line[0] == "#"
    next
  end
  line.match(/resource\/([^>]*).*resource\/Category:([^>]*)/) do |match|
    article = match[1]
    article_id = article_ids_by_url[article]
    if article_id.nil?
      redirected_article = redirects[article]
      article_id = article_ids_by_url[redirected_article] if redirected_article
      found_redirect += 1
    end
    #puts "Could not find article: #{article} #{redirected_article}" if article_id.nil?
    category = match[2]
    category_id = category_ids_by_url[category]
    #puts "Could not find category: #{category}" if category_id.nil?
    if article_id && category_id
      categories[category_id] << article_id
      found += 1
    else
      missing += 1
    end
    
    i += 1
    if i % 100000 == 0
      puts i
    end
  end  
end

puts "Found: #{found}, Missing: #{missing}"
puts "Found-Redirect: #{found_redirect}"

dump(categories, 'categories')
