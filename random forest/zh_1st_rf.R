# Load libraries
library(caret)

# Define the parameter grid for mtry
tune_grid <- expand.grid(.mtry = 29)

# Define the control parameters for training
train_control <- trainControl(method = "cv", number = 10,
                              savePredictions = "all",  # save predictions from each fold
                              classProbs = TRUE,  # IMPORTANT: This needs to be set to TRUE
                              summaryFunction = multiClassSummary,  # Compute multi-class summary metrics
                              verboseIter = TRUE)

# Train the model
rf_model <- train(target ~ ., 
                  data = df, 
                  method = "rf", 
                  ntree = 2000, 
                  tuneGrid = tune_grid, 
                  trControl = train_control)

# Print the model to see the results
print(rf_model)

# to predict on actual test data
# Load library
library(dplyr)

# Replace new levels with the most common level in the training data
testdata$income[testdata$income %in% c("$240,000 to $249,999", "$260,000 to $269,999")] <-"$270,000 to $279,999"

# Assuming your test data is in a dataframe named testdata
# Make predictions
predictions <- predict(rf_model, newdata = testdata, type = "prob")


# Convert the column to a data frame
no_col <- data.frame(No = testdata[["No"]])

# Combine the data frames
predictions <- bind_cols(no_col, predictions)

# Write to CSV
write.csv(predictions, "predictions.csv", row.names = FALSE)
