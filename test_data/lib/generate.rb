
File.open("long_abstracts.txt","w") do |file|
  14.times do |i|
    text = 100.times.map { |word| "word#{word}" }.join(" ")
    file.puts("<http://dbpedia.org/resource/Article#{i}> <http://dbpedia.org/ontology/abstract> \"#{text}\"@en .")
  end
end

File.open("article_labels.txt","w") do |file|
  14.times do |i|
    file.puts("<http://dbpedia.org/resource/Article#{i}> <httpd://www.w3.org/2000/01/rdf-schema#label> \"Article #{i}\"@en .")
  end
end

File.open("category_labels.txt","w") do |file|
  7.times do |i|
    file.puts("<http://dbpedia.org/resource/Category:Category#{i}> <http://www.w3.org/2000/01/rdf-schema#label> \"Category #{i}\"@en .")
  end
end

File.open("article_categories.txt","w") do |file|
  (14.times.map { |i| [i, i/2] } + [[10, 1],[12,1],[2,5],[6,5]]).each do |artId, catId|
    file.puts("<http://dbpedia.org/resource/Article#{artId}> <http://purl.org/dc/terms/subject> <http://dbpedia.org/resource/Category:Category#{catId}> .")
  end
end

File.open("skos_categories.txt","w") do |file|
  [[0,1],[0,2],[1,3],[1,4],[2,5],[2,6]].each do |parentId, childId|
    file.puts("<http://dbpedia.org/resource/Category:Category#{childId}> <http://www.w3.org/2004/02/skos/core#broader> <http://dbpedia.org/resource/Category:Category#{parentId}> .")
  end
end





  
