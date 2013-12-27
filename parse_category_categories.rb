#!/usr/bin/env ruby
require 'set'

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

category_ids_by_url = load('category_ids_by_url')
category_count = category_ids_by_url.size
puts "Categories: #{category_count}"

category_children = Array.new(category_count) { [] }
category_is_root = Array.new(category_count, true)

i = 0
successes = 0
failures = 0
ARGF.each do |line|
  if line[0] == "#"
    next
  end
  line.match(/Category:([^>]*).*skos\/core#broader.*Category:([^>]*)/) do |match|
    child = category_ids_by_url[match[1]]
    parent = category_ids_by_url[match[2]]
    
    if child && parent
      category_children[parent] << child
      category_is_root[child] = false
      successes += 1
    else
      failures += 1
    end

    i += 1
    if i % 100000 == 0
      puts "#{i} Successes: #{successes} Failures: #{failures}"
    end
  end
end
puts "#{i} Successes: #{successes} Failures: #{failures}"

@category_children = category_children
@categories = load('categories')
puts "loaded categories"
puts "merging category heirarchy"

def combine_child_categories(category, route=[])

  if route.include?(category)
    #loop!
    puts "Loop: #{category}"
    puts route
    return Set.new
  end
  category_documents = @categories[category]
  
  route.push category
  @category_children[category].each do |child_category|
    category_documents |= combine_child_categories(child_category, route)
  end
  route.pop
  @category_children[category] = []

  @categories[category] = category_documents
  category_documents
end

category_is_root.each_with_index do |is_root, category|
  i += 1
  if i % 100000 == 0
    puts i
  end
  combine_child_categories(category) if is_root
end
dump(@categories,'categories_merged')
