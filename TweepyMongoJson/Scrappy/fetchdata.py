from database import Database
import json

db = Database.initialize()

values = Database.find(collection='twitter_search', query={})

for value in values:
    print(value['text'])

