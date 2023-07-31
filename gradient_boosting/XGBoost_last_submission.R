set.seed(123)
library(dplyr)

df <- read.csv("RF Spam/trainedit.csv")
testdata <- read.csv("RF Spam/testedit.csv")
# Combine choice columns into a single target column
# Combine choice columns into a single target column
df$target <- ifelse(df$Ch1 == 1, '1',
                    ifelse(df$Ch2 == 1, '2',
                           ifelse(df$Ch3 == 1, '3', '4')))

#testdata$target <- ifelse(testdata$Ch1 == 1, '1',
#                    ifelse(testdata$Ch2 == 1, '2',
#                           ifelse(testdata$Ch3 == 1, '3', '4')))


# Remove choice columns
df$Ch1 <- NULL
df$Ch2 <- NULL
df$Ch3 <- NULL
df$Ch4 <- NULL

# Remove choice columns
testdata$Ch1 <- NULL
testdata$Ch2 <- NULL
testdata$Ch3 <- NULL
testdata$Ch4 <- NULL

# Convert to a numeric and subtract 1
df$target <- as.numeric(df$target) - 1

# Convert to a numeric and subtract 1
#testdata$target <- as.numeric(testdata$target) - 1


# Remove any rows where target is NaN or Inf
#df <- traindata[!is.na(traindata$target) & traindata$target != Inf, ]

# Define the labels
labels <- df$target

# Create the design matrix, excluding the target variable
data_matrix <- model.matrix(~.-1 -target, data = df)  # Assuming 'target' is the name of your target variable

# Create the DMatrix
dtrain <- xgb.DMatrix(data = data_matrix, label = labels)

# Define parameters
params <- list(booster = "gbtree",
               objective = "multi:softprob",
               num_class = length(unique(labels)),  # number of classes
               eta = 0.3,
               gamma = 0,
               max_depth = 6,
               min_child_weight = 1,
               subsample = 1,
               colsample_bytree = 1)

# Use cross-validation to find optimal number of rounds
cv_model <- xgb.cv(params = params, 
                   data = dtrain, 
                   nrounds = 100, 
                   nfold = 10, 
                   early_stopping_rounds = 10, 
                   prediction = TRUE)

# Get the number of the best iteration
best_nrounds <- cv_model$best_iteration

# Train the final model with the optimal number of rounds
best_xgb_model <- xgb.train(params = params, 
                            data = dtrain, 
                            nrounds = best_nrounds)
# Extract the evaluation log
evaluation_log <- cv_model$evaluation_log

# Print the logloss for the last iteration
print(evaluation_log$test_mlogloss_mean[best_nrounds])

testdata_matrix <- model.matrix(~. - 1, data = testdata)  

# Create the DMatrix for xgboost
dtest <- xgb.DMatrix(data = testdata_matrix)

# Now you can make predictions on your test data:
predictions_xgb <- predict(best_xgb_model, newdata = dtest)

# Reshape the predictions vector to a matrix
predictions_matrix <- matrix(predictions_xgb, ncol = 4, byrow = TRUE)

# Convert to a data frame and set the column names
predictions_xgb <- as.data.frame(predictions_matrix)
colnames(predictions_xgb) <- c("Ch1", "Ch2", "Ch3", "Ch4")

# Convert the column to a data frame
no_col <- data.frame(No = testdata[["No"]])

# Combine the data frames
predictions_xgb <- bind_cols(no_col, predictions_xgb)
head(predictions_xgb)

write.csv(predictions_xgb, file = "submission final.csv", row.names=TRUE)
