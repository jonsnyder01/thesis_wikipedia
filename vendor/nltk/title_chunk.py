import json
import fileinput
import nltk
import pprint

tagger = nltk.tag.perceptron.PerceptronTagger()
grammar = r"""
NP:
  {<DT>?<JJ.*>*<NN.*>+}
"""
chunking_parser = nltk.RegexpParser(grammar)

for line in fileinput.input():
  o = json.loads(line)
  if o['sentences']:
    noun_phrases = []
    for sentence in o['sentences']:

      pos_tags = tagger.tag(sentence)
      chunks = chunking_parser.parse(pos_tags)
      for subtree in chunks.subtrees():
        if subtree.label() == 'NP':
          noun_phrases.append([leaf[0] for leaf in subtree.leaves()])
      o['phrases'] = noun_phrases
  print json.dumps(o)
