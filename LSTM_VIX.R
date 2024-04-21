# Load necessary libraries
library(keras)
library(dplyr)
library(tibble)

# Load the US VIX data
vix_data <- read.csv("path_to_us_vix_data.csv")

# Convert date column to date format and sort the data
vix_data$Date <- as.Date(vix_data$Date)
vix_data <- vix_data %>%
  arrange(Date)

# Normalize the US VIX data
vix_data$US_VIX <- (vix_data$US_VIX - min(vix_data$US_VIX)) / (max(vix_data$US_VIX) - min(vix_data$US_VIX))

# Prepare the data for LSTM
n_lag <- 10  # Number of lag days to include in each sequence

# Create sequences and targets
input_seqs <- list()
targets <- c()

# Iterate through the data starting from index n_lag to create sequences and targets
for (i in seq(n_lag, nrow(vix_data) - 1)) {
    # Get the sequence from (i - n_lag) to i
    input_seq <- vix_data$US_VIX[(i - n_lag + 1):i]
    
    # Get the target value (i + 1)
    target <- vix_data$US_VIX[i + 1]
    
    # Append the sequence and target to the lists
    input_seqs[[length(input_seqs) + 1]] <- input_seq
    targets[length(targets) + 1] <- target
}

# Convert the input sequences and targets to arrays
input_data <- array(unlist(input_seqs), dim = c(length(input_seqs), n_lag, 1))
target_data <- array(targets, dim = c(length(targets), 1))

# Split the data into training and testing sets (80-20 split)
split_point <- floor(0.8 * nrow(sequences))
train_indices <- 1:split_point
test_indices <- (split_point + 1):nrow(sequences)

train_input <- input_data[train_indices, , ]
train_target <- target_data[train_indices, ]
test_input <- input_data[test_indices, , ]
test_target <- target_data[test_indices, ]

# Build the LSTM model
model <- keras_model_sequential() %>%
  layer_lstm(units = 50, input_shape = c(n_lag, 1), return_sequences = FALSE) %>%
  layer_dense(units = 1)

# Compile the model
model %>% compile(
  optimizer = "adam",
  loss = "mean_squared_error",
  metrics = c("mean_absolute_error")
)

# Train the model
history <- model %>% fit(
  train_input,
  train_target,
  epochs = 100,
  batch_size = 16,
  validation_data = list(test_input, test_target),
  verbose = 1
)

# Predict on the test set
predictions <- model %>% predict(test_input)

# Evaluate model performance
mse <- mean((test_target - predictions)^2)
print(paste("MSE:", round(mse, 4)))

# You can visualize predictions vs. actual values
plot(test_indices, test_target, type = "l", col = "blue", ylab = "Normalized US VIX", xlab = "Index")
lines(test_indices, predictions, col = "red")
legend("topright", legend = c("Actual", "Predicted"), col = c("blue", "red"), lty = 1)
