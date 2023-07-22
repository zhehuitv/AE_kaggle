install.packages("devtools")
install.packages("readr")
library(readr)

devtools::install_github('rstudio/tensorflow')
install.packages("reticulate")

library(reticulate)
library(tensorflow)
library("keras")

reticulate::py_config()
rm(list=ls())

data <- read_csv("train1.csv")
str(data)

# Shuffle the data
set.seed(123) # for reproducibility
data <- data[sample(nrow(data)),]

# Split into features and targets
features <- as.matrix(data[,4:83])
targets <- as.matrix(data[,110:113])
# Determine the row to split on
split_row <- round(0.8 * nrow(data))  # 80% for training, 20% for validation

# Create training set
train_features <- features[1:split_row, ]
train_targets <- targets[1:split_row, ]


# Create validation set
val_features <- features[(split_row+1):nrow(data), ]
val_targets <- targets[(split_row+1):nrow(data), ]

# Initialize the model
model <- keras_model_sequential()

# Add layers
model$add(layer_dense(units = 256, activation = 'relu', input_shape = ncol(train_features)))
model$add(layer_dropout(rate = 0.4))
model$add(layer_dense(units = 128, activation = 'relu'))
model$add(layer_dropout(rate = 0.3))
model$add(layer_dense(units = ncol(train_targets), activation = 'sigmoid'))

# Compile the model
model$compile(
  loss = 'binary_crossentropy',
  optimizer = optimizer_rmsprop(),
  metrics = c('accuracy')
)

# Fit the model
history <- model$fit(
  train_features,
  train_targets,
  epochs = as.integer(20),
  batch_size = as.integer(32),
  validation_data = list(val_features, val_targets)
)

# Evaluate the model on the validation set
model$evaluate(val_features, val_targets)


predictions_binary <- ifelse(predictions >= 0.5, 1, 0)
print(predictions_binary)




test_data <- read_csv("test1.csv")

# Make sure to apply any transformations that were applied to the training data
# on the test data as well.

test_features <- as.matrix(test_data[,4:83])

# Predict target values
test_predictions <- model$predict(test_features)

# If you want to convert the probabilities into binary classes
test_predictions_binary <- ifelse(test_predictions >= 0.3, 1, 0)

# Insert predictions into the original data frame
test_data[,110:113] <- test_predictions_binary

prediction<-test_data[,110:113]
test_prediction_df <- as.data.frame(test_predictions)
write.csv(test_prediction_df, "test_predictions.csv", row.names = FALSE)
write_csv(test_predictions, "tes4.csv")



