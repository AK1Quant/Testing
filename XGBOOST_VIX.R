# Load necessary libraries
library(xgboost)
library(dplyr)
library(tibble)

# Load the US VIX data
vix_data <- read.csv("path_to_us_vix_data.csv")

# Convert date column to date format and sort the data
vix_data$Date <- as.Date(vix_data$Date)
vix_data <- vix_data %>%
  arrange(Date)

# Feature engineering: create lag features and moving averages
vix_data <- vix_data %>%
  mutate(
    lag1 = lag(US_VIX, 1),
    lag2 = lag(US_VIX, 2),
    lag3 = lag(US_VIX, 3),
    ma3 = rollmean(US_VIX, 3, fill = NA),
    ma5 = rollmean(US_VIX, 5, fill = NA)
  )

# Remove rows with NA values
vix_data <- vix_data %>%
  na.omit()

# Split data into training and testing sets (80-20 split)
split_point <- floor(0.8 * nrow(vix_data))
train_data <- vix_data[1:split_point, ]
test_data <- vix_data[(split_point + 1):nrow(vix_data), ]

# Convert data to DMatrix format
train_matrix <- as.matrix(train_data[, -1])  # Exclude Date column
train_label <- train_data$US_VIX
train_dmatrix <- xgb.DMatrix(data = train_matrix, label = train_label)

test_matrix <- as.matrix(test_data[, -1])
test_label <- test_data$US_VIX
test_dmatrix <- xgb.DMatrix(data = test_matrix, label = test_label)

# Set up parameters for XGBoost model
params <- list(
  objective = "reg:squarederror",
  booster = "gbtree",
  eta = 0.1,  # Learning rate
  max_depth = 6,  # Maximum tree depth
  eval_metric = "rmse"
)

# Train the XGBoost model
nrounds <- 100
model <- xgboost(
  data = train_dmatrix,
  params = params,
  nrounds = nrounds,
  watchlist = list(train = train_dmatrix, eval = test_dmatrix),
  verbose = 1
)

# Predict on the test set
predictions <- predict(model, test_dmatrix)

# Evaluate model performance
rmse <- sqrt(mean((test_label - predictions)^2))
print(paste("RMSE:", round(rmse, 2)))

# You can also visualize predictions vs. actual values
plot(test_data$Date, test_label, type = "l", col = "blue", ylab = "US VIX", xlab = "Date")
lines(test_data$Date, predictions, col = "red")
legend("topright", legend = c("Actual", "Predicted"), col = c("blue", "red"), lty = 1)
