#Read data
df <- read.csv("processeddata2.csv")
#processeddata2 is derived from running dfidx on train data. I removed the non-index columns as well.

# Load the necessary library
library(randomForest)
library(nnet)  # for class.ind() function

# Combine choice columns into a single target column
df$target <- ifelse(df$Ch1 == 1, 'Ch1',
                    ifelse(df$Ch2 == 1, 'Ch2',
                           ifelse(df$Ch3 == 1, 'Ch3', 'Ch4')))

# Remove choice columns
df$Ch1 <- NULL
df$Ch2 <- NULL
df$Ch3 <- NULL
df$Ch4 <- NULL
df$Choice <- NULL

# Split dataset into training and test datasets
set.seed(123)  # Setting seed to reproduce results of random sampling
trainingRowIndex <- sample(1:nrow(df), 0.8*nrow(df))  # row indices for training data
trainingData <- df[trainingRowIndex, ]  # model training data
testData  <- df[-trainingRowIndex, ]   # test data

# Convert the target column to factor
trainingData$target <- as.factor(trainingData$target)
testData$target <- as.factor(testData$target)

# Train the model
set.seed(123)
rf_model <- randomForest(target~., data=trainingData, ntree=500, importance=TRUE)

# Print model
print(rf_model)

# Predict using the model and get probabilities
predicted_probs <- predict(rf_model, newdata=testData, type="prob")

# Print the first few lines of predicted probabilities
print(head(predicted_probs))

# Convert true classes to one-hot encoding
labels_one_hot <- class.ind(testData$target)

# Calculate log loss
log_loss <- -mean(log(predicted_probs) * labels_one_hot)
print(paste('Log Loss:', round(log_loss, 4)))


# Create a data frame from the predicted probabilities
output <- as.data.frame(predicted_probs)
output$Task <- testData$Task

# Order the columns
output <- output[c("Task", "Ch1", "Ch2", "Ch3", "Ch4")]

# Write to CSV
write.csv(output, file = "predicted_probabilitiesnew.csv", row.names=FALSE)

#Test set prediction
test <- read.csv("test1.csv")
test$Choice <- 1 # add choice column

# preparing test data to be in same dfidx format
library(mlogit)
test <- dfidx(subset(test, Task<=19), shape="wide", 
              choice="Choice", sep="", varying = c(4:83), 
              idx = c("No","Case"))

write.csv(test, file = "testfile.csv", row.names = FALSE)

test <- read.csv("testfile.csv")

predicted_test <- predict(rf_model, newdata=test, type="prob")

# Print the first few lines of predicted probabilities
print(head(predicted_test))

df <- predicted_test

# Create a new variable that will be used to group every 4 rows
df$group <- ceiling((1:nrow(df))/4)

# Calculate the mean of each group
mean_df <- df %>%
  group_by(group) %>%
  summarise(across(everything(), mean, na.rm = TRUE)) %>%
  select(-group)

# Print the output dataframe
print(mean_df)

