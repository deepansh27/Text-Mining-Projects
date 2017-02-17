# Chap01/demo_gensim.py
from gensim.summarization import summarize,keywords




file = open('input.txt')
text= file.read()



print ('Summary:')
print (summarize(text, ratio=0.01))

print ('\nKeywords:')
print (keywords(text, ratio=0.01))
