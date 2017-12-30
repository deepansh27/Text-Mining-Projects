Mining-Twitter-Data-for-Sentiment-Analysis


Sentiment Analysis using tweepy,NLTK and Textblob

Using tweepy extract all the tweets related to the given Topics:


from twitterStreamer import StreamListener
import tweepy

Topics = ['#bigdata', '#AI', '#datascience', '#machinelearning', '#ml', '#iot']

CONSUMER_KEY = ""
CONSUMER_SECRET = ""
ACCESS_TOKEN = ""
ACCESS_TOKEN_SECRET = ""


auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_TOKEN, ACCESS_TOKEN_SECRET)



#Set up the listener. The 'wait_on_rate_limit=True' is needed to help with Twitter API rate limiting.

listener = StreamListener(api=tweepy.API(wait_on_rate_limit=True))
streamer = tweepy.Stream(auth=auth, listener=listener)
print("Tracking: " + str(Topics))
streamer.filter(track=Topics)





Inserting the tweets into MongoDB :



def on_data(self, data):
   # This is the meat of the script...it connects to your mongoDB and stores the tweet
   try:
       # Use twitterdb database. If it doesn't exist, it will be created.
       db = Database.initialize()

       # Decode the JSON from Twitter
       datajson = json.loads(data)

       # grab the 'created_at' data from the Tweet to use for display
       created_at = datajson['created_at']

       # print out a message to the screen that we have collected a tweet
       print("Tweet collected at " + str(created_at))

       # insert the data into the mongoDB into a collection called twitter_search
       # if twitter_search doesn't exist, it will be created.
       Database.insert('twitter_search', datajson)
   except Exception as e:
       print(e)




text: the text of the tweet itself
created_at: the date of creation
favorite_count, retweet_count: the number of favourites and retweets
favorited, retweeted: boolean stating whether the authenticated user (you) have favourited or retweeted this tweet
lang: acronym for the language (e.g. “en” for english)
id: the tweet identifier
place, coordinates, geo: geo-location information if available
user: the author’s full profile
entities: list of entities like URLs, @-mentions, hashtags and symbols
in_reply_to_user_id: user identifier if the tweet is a reply to a specific user
in_reply_to_status_id: status identifier id the tweet is a reply to a specific status


Processing tweets:


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

   def tokenize(self, s):
       return self.tokens_re.findall(s)

   def preprocess(self, s, lowercase=True):
       tokens = self.tokenize(s)
       if lowercase:
           tokens = [token if self.emoticon_re.search(token) else token.lower() for token in tokens]
       return tokens










Sentiment Analysis refers to the process of taking natural language to identify and extract subjective information. You can take text, run it through the TextBlob and the program will spit out if the text is positive, neutral, or negative by analyzing the language used in the text.

Sentiment Analysis
Text	If that is not cool enough for you than that is a you problem.
Polarity	-0.0875
Subjectivity	0.575
Classification	neg
P_Pos	0.344455873
P_Neg	0.655544127
What does that mean?

Polarity - a measure of the negativity, the neutralness, or the positivity of the text
Classification - either pos or neg indicating if the text is positive or negative
To calculate the overall sentiment, we look at the polarity score:


tweets = Database.find(collection='twitter_search', query={})
lis = []
neg = 0.0
n = 0.0
net = 0.0
pos = 0.0
p = 0.0
cout = 0
for tweet in tweets:
   # Create a list with all the terms
   blob = TextBlob(tweet["text"])
   cout += 1
   lis.append(blob.sentiment.polarity)
   # print blob.sentiment.subjectivity
   # print (os.listdir(tweet["text"]))
   if blob.sentiment.polarity < 0:
       sentiment = "negative"
       neg += blob.sentiment.polarity
       n += 1
   elif blob.sentiment.polarity == 0:
       sentiment = "neutral"
       net += 1
   else:
       sentiment = "positive"
       pos += blob.sentiment.polarity
       p += 1

   # output sentiment

print "Total tweets", len(lis)
print "Positive ", float(p / cout) * 100, "%"
print "Negative ", float(n / cout) * 100, "%"
print "Neutral ", float(net / len(lis)) * 100, "%"



