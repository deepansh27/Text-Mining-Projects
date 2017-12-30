from common.database import Database


db = Database.initialize()

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
