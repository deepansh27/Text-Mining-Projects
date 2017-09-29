install.packages("caret")
library(caret)
install.packages('e1071', dependencies=TRUE)
library(tm)
rm(list= ls())
library(e1071)
# this is the training data
data <- c('Cats like to chase mice.', 'Dogs like to eat big bones.')
corpus <- Corpus(VectorSource(data))
?DocumentTermMatrix
# Creating a document term matrix
tdm <- DocumentTermMatrix(corpus, list(removePunctuation = TRUE, stopwords = TRUE, stemming = TRUE, removeNumbers = TRUE))
class(tdm)
# Convert to a data.frame for training and assign a classification (factor) to each document.
train <- as.matrix(tdm)
train <- cbind(train, c(0, 1))
colnames(train)[ncol(train)] <- 'y'
train <- as.data.frame(train)
train$y <- as.factor(train$y)

# Training 
fit <- train(y ~ ., data = train, method = 'bayesglm')

# Check accuracy on training  .
predict(fit, newdata = train)

# Test data.
data2 <- c('dogs bone')
data2<-c('I chase mice')
corpus <- Corpus(VectorSource(data2))
tdm <- DocumentTermMatrix(corpus, control = list(dictionary = Terms(tdm)))
test <- as.matrix(tdm)

# Check accuracy on test.
predict(fit, newdata = test)
predict(fit, newdata = test)