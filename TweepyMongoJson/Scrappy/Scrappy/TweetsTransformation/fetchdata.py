from common.database import Database
from datapreprocessing import Preprocess
from nltk.corpus import stopwords
import string
from nltk import bigrams
from collections import Counter


class TransformedTweeets(object):

    db = Database.initialize()

    def transformed_tweets(self):
        punctuation = list(string.punctuation)
        stop = stopwords.words('english') + punctuation + ['rt', 'via']
        tweets = Database.find(collection='twitter_search', query={})
        prep = Preprocess()
        for tweet in tweets:
            # Create a list with all the terms
            terms_stop = [term for term in prep.preprocess(tweet['text']) if term not in stop]
            # Update the counter
            # terms_single = set(terms_all)
            # Count hashtags only
            terms_hash = [term for term in prep.preprocess(tweet['text'])
                          if term.startswith('#')]
            # Count terms only (no hashtags, no mentions)
            terms_only = [term for term in prep.preprocess(tweet['text'])
                          if term not in stop and
                          not term.startswith(('#', '@','\u'))]
            # mind the ((double brackets))
            # startswith() takes a tuple (not a list) if
            # we pass a list of inputs
            terms_single = set(terms_only)
            terms_bigram = bigrams(terms_only)
        return terms_only



