library(dfidx)
data <- read.csv('train1.csv')
test <- read.csv('test1.csv')

# to create a Choice column that was in W4 csv
which_is_one <- function(row) {
  return(which(row == 1)[1])
}
data$Choice <- apply(data[,c('Ch1', 'Ch2', 'Ch3', 'Ch4')], 1, which_is_one)

# converting training data into dfidx format
library(mlogit)
S <- dfidx(subset(data, Task<=19), shape="wide", 
           choice="Choice", sep="", varying = c(4:83), 
           idx = c("No","Case")) 

# create the mlogit model 
M <- mlogit(Choice~CC+GN+NS+BU+FA+LD+BZ+FC+FP+RP+PP+KA+SC+TS+NV+MA+LB+AF+HU+Price-1, data=S)
summary(M)

# predicting on training data
ActualChoice <- subset(data, Task<=19)[,"Choice"]
P <- predict(M, newdata=S)
PredictedChoice <- apply(P,1,which.max)

# preparing test data to be in same dfidx format
test <- dfidx(subset(data, Task<=19), shape="wide", 
              choice="Choice", sep="", varying = c(4:83), 
              idx = c("No","Case"))

# Predicting on test set
PredictTest <- predict(M, newdata=test)
PredictedChoice <- apply(PredictTest,1,which.max)

# Create matrix to store predicted data
mat <- sapply(1:4, function(x) as.integer(PredictedChoice == x))

# Convert matrix to dataframe
submission <- as.data.frame(mat)

# Set column names
colnames(submission) <- paste0("Ch", 1:4)

# writing the data to the sample submission file
existing <- read.csv("first_predictions.csv")
existing[, c("Ch1", "Ch2", "Ch3", "Ch4")] <- PredictTest
write.csv(existing, "first_predictions.csv", row.names = FALSE)
