## Project : Word Cloud
## Developer : Deepansh Parab
rm(list = ls())
data <- read.csv("/Users/deepanshparab/Desktop/R/project/MyTweets.csv")

data_source <- data[,2]

library(tm)

myCorpus <- Corpus(VectorSource(iconv(data_source, "utf-8", "ASCII", sub="")))


myCorpus <- tm_map(myCorpus, content_transformer(tolower))

removeURL <- function(x) gsub("http[^[:space:]]*","", x)
myCorpus <-tm_map(myCorpus, content_transformer(removeURL))

# remove anything other than English letters or space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*","",x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))


# add two extra words: "available" and "via"
myStopwords <- c(stopwords('english'),"rt","available","via","0","character","109","117","15","20","3","37","4")
# remove "r" and "big" from stopwords
#myStopwords <- setdiff(myStopwords, c("rt","big"))
# remove stopwords from corpus
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

#remove extra whitespace
myCorpus <- tm_map(myCorpus, stripWhitespace)
# keep a copy of corpus to use later as a dictionary for stem completion
myCorpus <- tm_map(myCorpus, removeNumbers)

inspect(myCorpus)
myCorpus <- tm_map(myCorpus, removeWords, c("north", "koreas","korean"))
#inspect(myCorpus[1:10])
myCorpusCopy <- myCorpus
#inspect(myCorpus)



?TermDocumentMatrix

tdm <- TermDocumentMatrix(myCorpus ,control = list(wordLengths = c(1,Inf), stopwords= TRUE))
tdm



?findFreqTerms
(freq.terms <- findFreqTerms(tdm, lowfreq = 15))






