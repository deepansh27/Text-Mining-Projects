##***********************************************************************************************
##Project : Topic Modelling Using R
##Developer : Sravanthi Kanchi
##Date : 2nd May 2017
##***********************************************************************************************


install.packages("tm")  
install.packages("topicmodels")

rm(list=ls()) # removes all the global directory 
library(tm)

##***********************************************************************************************
##EXTRACRION
##***********************************************************************************************
# Setting the working directory as follows
setwd("/Users/deepanshparab/Desktop/data")  #make sure you give it the path where you will store the the 30 text files

#load files into corpus
#get listing of .txt files in directory
filenames <- list.files(getwd(),pattern="*.txt") 


#read files into a character vector
files <- lapply(filenames,readLines)

#create corpus from vector
docs <- Corpus(VectorSource(files))
#inspect(docs)

#inspect a particular document in corpus
#writeLines(as.character(docs[[1]]))
#writeLines(as.character(docs[[2]]))
#writeLines(as.character(docs[[25]]))
#writeLines(as.character(docs[[20]]))


##***********************************************************************************************
##EXTRACRION
##***********************************************************************************************
##preprocessing
#Transform to lower case
docs <-tm_map(docs,content_transformer(tolower))


#remove potentially problematic symbols
toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, " ", x))}) 
docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, " " )
docs <- tm_map(docs, toSpace, "•") 
docs <- tm_map(docs, toSpace, " ") 



#remove punctuation
docs <- tm_map(docs, removePunctuation)
#Strip digits
docs <- tm_map(docs, removeNumbers)
#remove stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
#writeLines(as.character(docs[[2]]))
#remove whitespace
docs <- tm_map(docs, stripWhitespace)
#Good practice to check every now and then

#Stem document
docs <- tm_map(docs,stemDocument)


#fix up 1) differences between us and aussie english 2) general errors
docs <- tm_map(docs, content_transformer(gsub), pattern = "organiz", replacement = "organ")
docs <- tm_map(docs, content_transformer(gsub),pattern = "organis", replacement = "organ")
docs <- tm_map(docs, content_transformer(gsub), pattern = "andgovern", replacement = "govern") 
docs <- tm_map(docs, content_transformer(gsub), pattern = "inenterpris", replacement = "enterpris") 
docs <- tm_map(docs, content_transformer(gsub), pattern = "team-", replacement = "team")
docs <- tm_map(docs,content_transformer(gsub),pattern ="itxx", replacement="its")
#define and eliminate all custom stopwords 
myStopwords <- c("its","the","are","that","have","was","this","can", "say","one","way","use", "also","howev","tell","will", "much","need","take","tend","even", "like","particular","rather","said", "get","well","make","ask","come","end", "first","two","help","often","may", "might","see","someth","thing","point", "post","look","right","now","think","‘ve ","‘re ","anoth","put","set","new","good", "want","sure","kind","larg","yes,","day","etc", "quit","sinc","attempt","lack","seen","awar", "littl","ever","moreov","though","found","abl", "enough","far","earli","away","achiev","draw", "last","never","brief","bit","entir","brief", "great","lot")
docs <- tm_map(docs, removeWords, myStopwords)

#inspect(docs)

##***********************************************************************************************
##LOADING
##***********************************************************************************************
#Create document-term matrix
dtm <- DocumentTermMatrix(docs)
inspect(dtm)
#convert rownames to filenames
rownames(dtm) <- filenames
#collapse matrix by summing over columns
freq <- colSums(as.matrix(dtm))
#length should be total number of terms
length(freq)
#create sort order (descending)
ord <- order(freq,decreasing=TRUE)
#List all terms in decreasing order of freq and write to disk
freq[ord] 
write.csv(freq[ord],"/Users/deepanshparab/Desktop/Rword_freq.csv")


##***********************************************************************************************
##TOPIC MODELLING USING LDA
##***********************************************************************************************

#load topic models library
library(topicmodels)

#Set parameters for Gibbs sampling
burnin <- 4000
iter <- 2000
thin <- 500
seed <-list(2003,5,63,100001,765) 
nstart <- 5
best <- TRUE

#Number of topics
k <- 5


daOut <-LDA(dtm,k, method="Gibbs", control=list(nstart=nstart, seed = seed, best=best, burnin = burnin, iter = iter, thin=thin))

daOut.topics <- as.matrix(topics(daOut))



daOut.terms <- as.matrix(terms(daOut,15))

#probabilities associated with each topic assignment
topicProbabilities <- as.data.frame(daOut@gamma)

#Find relative importance of top 2 topics


