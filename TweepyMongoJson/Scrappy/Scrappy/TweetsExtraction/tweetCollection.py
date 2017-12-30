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






