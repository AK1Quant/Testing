import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense

# Load the data
data = pd.read_csv('path_to_your_data.csv', parse_dates=['Date'])
data.set_index('Date', inplace=True)


# Split the data into training and testing sets
train_size = int(len(data) * 0.8)
train_data = data[:train_size]
test_data = data[train_size:]

# Prepare data for LSTM
def create_sequences(data, seq_length):
    sequences = []
    targets = []
    for i in range(len(data) - seq_length):
        sequences.append(data[i:i + seq_length])
        targets.append(data[i + seq_length])
    # Debug print statements
    print(f"Created {len(sequences)} sequences and {len(targets)} targets")
    print(f"Sample sequence: {sequences[0]}")
    print(f"Sample target: {targets[0]}")
    return np.array(sequences), np.array(targets)
    
seq_length = 10  # Change as desired
X_train, y_train = create_sequences(train_data, seq_length)
X_test, y_test = create_sequences(test_data, seq_length)
# test_data = test_data.reshape(-1, 1)
# Check test data format and adjust if necessary
# if isinstance(test_data, pd.DataFrame):
#     test_data = test_data.values
# test_data = test_data.reshape(-1, 1)  # Reshape to ensure it's a 1D array if necessary

# Debugging checks
print(f"Length of test data: {len(test_data)}")
print(f"First few rows of test_data: {test_data[:5]}")
# Check for missing values in test_data
if np.isnan(test_data).any():
    test_data = np.nan_to_num(test_data)  # Replace NaNs with zeros


# Generate sequences and targets for test data
X_test, y_test = create_sequences(test_data, seq_length)

# Reshape data for LSTM input
X_train = X_train.reshape(X_train.shape[0], X_train.shape[1], 1)
X_test = X_test.reshape(X_test.shape[0], X_test.shape[1], 1)

# Create and compile the LSTM model
model = Sequential()
model.add(LSTM(50, return_sequences=True, input_shape=(seq_length, 1)))
model.add(LSTM(50))
model.add(Dense(1))

model.compile(optimizer='adam', loss='mean_squared_error')

# Train the model
history = model.fit(X_train, y_train, epochs=50, batch_size=32, validation_split=0.1)

# Evaluate the model
test_loss = model.evaluate(X_test, y_test)

# Make predictions
predictions = model.predict(X_test)
predictions = scaler.inverse_transform(predictions)  # Convert predictions back to original scale
y_test = scaler.inverse_transform(y_test)  # Convert y_test back to original scale

# Visualize the results
plt.figure()
plt.plot(range(len(y_test)), y_test, label='Actual')
plt.plot(range(len(predictions)), predictions, label='Predicted')
plt.legend()
plt.show()
