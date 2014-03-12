import json
import fileinput
from nltk.tokenize import sent_tokenize
from nltk.tokenize import word_tokenize


for line in fileinput.input():
  try:
    o = json.loads( line)
    if o['text']:
      splits = []
      sents = sent_tokenize( o['text'])
      for sent in sents:
        splits.append( {'raw': sent, 'tokens': word_tokenize(sent)})
      o['sentences'] = splits
      print json.dumps( o)
  except ValueError:
    pass

