import json
import re
import operator
from collections import Counter
import nltk
nltk.download('stopwords')
from nltk.corpus import stopwords
import string
from nltk import bigrams
from nltk.tokenize import word_tokenize
from database import Database
import json


class Preprocess(object):
    emoticons_str = r"""
            (?:
            [:=;] # Eyes
            [oO\-]? # Nose (optional)
            [D\)\]\(\]/\\OpP] # Mouth
             )"""

    regex_str = [
        emoticons_str,
        r'<[^>]+>',  # HTML tags
        r'(?:@[\w_]+)',  # @-mentions
        r"(?:\#+[\w_]+[\w\'_\-]*[\w_]+)",  # hash-tags
        r'http[s]?://(?:[a-z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-f][0-9a-f]))+',  # URLs
        r'(?:(?:\d+,?)+(?:\.?\d+)?)',  # numbers
        r"(?:[a-z][a-z'\-_]+[a-z])",  # words with - and '
        r'(?:[\w_]+)',  # other words
        r'(?:\S)'  # anything else
    ]

    tokens_re = re.compile(r'('+'|'.join(regex_str)+')', re.VERBOSE | re.IGNORECASE)
    emoticon_re = re.compile(r'^'+emoticons_str+'$', re.VERBOSE | re.IGNORECASE)

    db = Database.initialize()

    def tokenize(self, s):
        return tokens_re.findall(s)

    def preprocess(self, s, lowercase=False):
        tokens = tokenize(s)
        if lowercase:
            tokens = [token if emoticon_re.search(token) else token.lower() for token in tokens]
        return tokens

    punctuation = list(string.punctuation)
    stop = stopwords.words('english') + punctuation + ['rt', 'via']

    values = Database.find(collection='twitter_search', query={})

    for value in values:
        tweet = value['text']

        terms_stop = [term for term in preprocess(tweet)]
        terms_hash = [term for term in preprocess(tweet) if term.startswith('#')]
        terms_only = [term for term in preprocess(tweet) if term not in stop and not term.startswith(('#', '@'))]
        terms_single = set(terms_stop)
        terms_bigram = bigrams(terms_stop)
        count_all.update(terms_stop)

    print(count_all.most_common(20))


obj = Preprocess.preprocess()
