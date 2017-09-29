
#****************************************************************************************************************************************************
## Project1- Twitter Analysis Using TM & Other Modules ##
## DEveloper Name : Deepansh Parab ##
## Start Date: 13th April, 2017 ##
#****************************************************************************************************************************************************


rm(list= ls()) # to clear the global enviornment

#Installation of the needed packages
#****************************************************************************************************************************************************
list.of.packages <- c("twitteR", "tm", "SnowballC", "ggplot2", "RColorBrewer", "wordcloud", "topicmodels", "data.table" ,"syuzhet","lubridate","scales","reshape2","qplyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
install.packages("qplyr")
#****************************************************************************************************************************************************


#****************************************************************************************************************************************************
## Extraction Of the Data From Twitter  
#****************************************************************************************************************************************************    

library(twitteR)

setup_twitter_oauth('kizmwgp5SIeruTUEke7MCjaeM', 'nHz6vlbeFYZC3OX5hRIDoma6u7Kw7PwlbZBd24pe83pwU06hcw', '824661471699333124-IenORgvFIIG93zFoXOewiKrYhzirWw2',
                    '2bwKUlCgETyQ7Ahu8UhULHzeYKMdQaBaZLZmWx1fq2uOd' )
tweets <- userTimeline("NorthKoreaTop", n = 3200)  #This is the code to extract tweets from twitter
#str(tweets) # it tells us about the structure of the tweets
n.tweet <- length(tweets)
tweets.df <- twListToDF(tweets) #converting the lists of tweets into dataframe 
View(tweets.df)
new_df <- tweets.df[,1]  ## Selecting only the 1st column from the data frame

#write.csv(new_df, file = "/Users/deepanshparab/Desktop/CS-553/Text Mining Project /NorthKorea.csv") # saving this dataframe into a csv_file for offline use or incase 
# one cannot accesss the API data
#new_df <- read.csv("/Users/deepanshparab/Desktop/CS-553/Text Mining Project /NorthKorea.csv")

#****************************************************************************************************************************************************
## Transformation and Cleaning of the Data- Removing stop words, urls , numeric data and other stuff
#****************************************************************************************************************************************************

library(tm)

# build a corpus, and specify the source to be character vectors
myCorpus <-Corpus(VectorSource(iconv(new_df[,2], "utf-8", "ASCII", sub="")))

x<-as.character(myCorpus) # We will need this for sentiment analysis so just copying the corpus to a varaible x
inspect(myCorpus[1:6]) # inspect the 1st 6 lines form the corpus

# convert to lower case
myCorpus <- tm_map(myCorpus, content_transformer(tolower))

# remove URLs
removeURL <- function(x) gsub("http[^[:space:]]*","", x)
myCorpus <-tm_map(myCorpus, content_transformer(removeURL))
#inspect(myCorpus[1:6])

# remove anything other than English letters or space
removeNumPunct <- function(x) gsub("[^[:alpha:][:space:]]*","",x)
myCorpus <- tm_map(myCorpus, content_transformer(removeNumPunct))
#inspect(myCorpus[1:6])


# Removing extra add words which I feel are unnessary
myStopwords <- c(stopwords('english'),"rt","a","north","korea","of","the","new","call","calls","now","will","didnt","tells","get","dont","go","got","available","via","0","character","109","117","15","20","3","37","4")


myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

#remove extra whitespace
myCorpus <- tm_map(myCorpus, stripWhitespace)
# keep a copy of corpus to use later as a dictionary for stem completion
myCorpus <- tm_map(myCorpus, removeNumbers)
#inspect(myCorpus[1:10])
myCorpusCopy <- myCorpus
myCorpus <- tm_map(myCorpus, content_transformer(gsub), pattern = "koreas", replacement = "korea")


#****************************************************************************************************************************************************
## Loading Data 
#****************************************************************************************************************************************************
tdm <- TermDocumentMatrix(myCorpus, control = list(wordLengths = c(1,Inf)))
?TermDocumentMatrix
tdm
inspect(tdm)



#****************************************************************************************************************************************************
## Frequency Plotting  
#****************************************************************************************************************************************************
#inspect frequent words
(freq.terms <- findFreqTerms(tdm, lowfreq = 100)) # finding word freq here i am only considering words with occcur in atleast 100 docs to
# avoid over crowding 

# Creating a named vector with the frequency of the words
term.freq <- rowSums(as.matrix(tdm))
term.freq <- subset(term.freq, term.freq >= 100)
# Transforming a named vector to a dataframe
df <- data.frame(term = names(term.freq), freq = term.freq)

library(ggplot2)
p <- ggplot(df, aes(x = term, y = freq)) 
p <- p +  geom_bar(stat = "identity") 
p <- p +  xlab("Terms") + ylab("Count")
p <- p + coord_flip()
print(p)  #ploting the freq words on histograms


#****************************************************************************************************************************************************
# Word Association and Corelation 
#****************************************************************************************************************************************************

(freq.terms <- findFreqTerms(tdm, lowfreq = 50))

# Finding some associations
findAssocs(tdm, "us", 0.1) # findAssocs is used to find the association of various words with 
#respect to a particular word provided in " ".
findAssocs(tdm, "kim", 0.2)
findAssocs(tdm, "trump", 0.1)



#****************************************************************************************************************************************************
#Sentiment Analysis
#*********************************************************************************************************************
library(syuzhet)
library(lubridate)
library( ggplot2)
library(reshape2)
library(qplyr)

sentiment <- get_nrc_sentiment(x)


t<-as.matrix(sentiment)
#write.csv(sentiment, "/Users/deepanshparab/Desktop/R/project/MySentiments.csv")

getwd()

comments <- cbind(new_df,sentiment)

sentimentTotals <- data.frame(colSums(sentiment[,c(1:8)]))
names(sentimentTotals) <- "count"
sentimentTotals <- cbind("sentiment" = rownames(sentimentTotals), sentimentTotals)
rownames(sentimentTotals) <- NULL

ggplot(data = sentimentTotals, aes(x = sentiment, y = count)) +
  geom_bar(aes(fill = sentiment), stat = "identity") +
  theme(legend.position = "none") +
  xlab("Sentiment") + ylab("Total Count") + ggtitle("Total Sentiment Score for all Tweets")



#****************************************************************************************************************************************************
## Hiearchial clustering    
#*******************************************************************************************************************************************************
# remove sparse terms
tdm2 <- removeSparseTerms(tdm, sparse = 0.9)
# Showing the terms that are left for the analysis
print(dimnames(tdm2)$Terms)

m2 <- as.matrix(tdm2)

# cluster terms
distMatrix <-dist(scale(m2))
fit <- hclust(distMatrix, method = "ward.D2")

p <- plot(fit)
p <- rect.hclust(fit, k = 4) # fit into 6 clusters
print(p)
# Showing the groups
(groups <-cutree(fit, k = 4))
print(groups)



#********************************************************************************************
#Topic Modelling
#********************************************************************************************
dtm <- as.DocumentTermMatrix(tdm)
library(topicmodels)
library(data.table)

lda <- LDA(dtm, k = 8) # find 8 topics
(term <- terms(lda,6)) # first6 terms of every topic

term <- apply(term, MARGIN = 2, paste, collapse = ", ")

# first topic identified for every document (tweet)
topic <- topics(lda, 1)
topics <- data.frame(date=as.IDate(tweets.df$created), topic)
p <- qplot(date, ..count.., data=topics, geom = "density", fill = term[topic], position="stack")
print(p)


