# Install and load necessary packages
install.packages("neuralprophet")
library(neuralprophet)

# Step 1: Load the dataset
data <- read.csv("your_dataset.csv")  # Replace 'your_dataset.csv' with the path to your VIX dataset

# Step 2: Preprocess the data
data$DATE <- as.Date(data$DATE)  # Convert DATE column to Date format
colnames(data) <- c("ds", "y")  # Rename columns for NeuralProphet compatibility

# Step 3: Split the data into training and testing sets
train_data <- data[1:round(0.8*nrow(data)), ]
test_data <- data[(round(0.8*nrow(data)) + 1):nrow(data), ]

# Step 4: Instantiate the NeuralProphet model
model <- neural_prophet(data=train_data, 
                         n_changepoints = 10,  # You can adjust hyperparameters as needed
                         yearly_seasonality = "auto",
                         weekly_seasonality = "auto",
                         daily_seasonality = "auto")

# Step 5: Train the model
model <- fit_neural_prophet(model, 
                             epochs = 100)  # Adjust the number of epochs based on your data

# Step 6: Make predictions
future <- make_future_dataframe(model, data=test_data, periods=30)  # 30 is the number of future periods
forecast <- predict(model, future)

# Plotting the forecast
plot(forecast)