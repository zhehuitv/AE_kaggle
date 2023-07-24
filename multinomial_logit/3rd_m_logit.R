library(dfidx)
library(dplyr)
train <- read.csv('train1.csv')
test <- read.csv('test1.csv')

# to create a Choice column that was in W4 csv
which_is_one <- function(row) {
  return(which(row == 1)[1])
}
train$Choice <- apply(train[,c('Ch1', 'Ch2', 'Ch3', 'Ch4')], 1, which_is_one)

# converting training data into dfidx format
library(mlogit)
S <- dfidx(subset(train, Task<=19), shape="wide", 
           choice="Choice", sep="", varying = c(4:83), 
           idx = c("No","Case")) 

# create the mlogit model 
M <- mlogit(Choice~CC+GN+NS+BU+FA+LD+FP+RP+PP+KA+SC+TS+NV+MA+LB+HU+Price-1, data=S)
model_summary <- summary(M)


# adding choice column to test
test$Choice <- 1
#test_imp <- test[, -which(names(test) %in% 
#c("column1", "column2", "column3"))]

# preparing test data to be in same dfidx format
test <- dfidx(subset(test, Task<=19), shape="wide", 
              choice="Choice", sep="", varying = c(4:83), 
              idx = c("No","Case"))

# Predicting on test set
PredictTest <- predict(M, newdata=test)

# writing the data to the sample submission file
existing <- read.csv("3rd_mlogit_predictions.csv")
existing[, c("Ch1", "Ch2", "Ch3", "Ch4")] <- PredictTest
write.csv(existing, "3rd_mlogit_predictions.csv", row.names = FALSE)











