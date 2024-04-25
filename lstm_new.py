import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense

# Load the data
data = pd.read_csv('path_to_your_data.csv', parse_dates=['Date'])
data.set_index('Date', inplace=True)

# Preprocess the data
scaler = MinMaxScaler()
data['US_VIX'] = scaler.fit_transform(data['US_VIX'].values.reshape(-1, 1))

# Define function to create time steps
def create_time_steps(data, time_steps):
    X, y = [], []
    for i in range(len(data) - time_steps):
        X.append(data[i:i + time_steps].values)
        y.append(data[i + time_steps])
    return np.array(X), np.array(y)

# Define the number of time steps
time_steps = 10

# Prepare training data
X, y = create_time_steps(data['US_VIX'], time_steps)

# Reshape X for LSTM input
X = X.reshape((X.shape[0], X.shape[1], 1))

# Split the data into training and testing sets
train_size = int(len(X) * 0.8)
X_train, X_test = X[:train_size], X[train_size:]
y_train, y_test = y[:train_size], y[train_size:]

# Create and compile the LSTM model
model = Sequential()
model.add(LSTM(50, input_shape=(time_steps, 1)))
model.add(Dense(1))
model.compile(optimizer='adam', loss='mean_squared_error')

# Train the model
model.fit(X_train, y_train, epochs=50, batch_size=32, validation_data=(X_test, y_test))

# Make predictions
predictions = model.predict(X_test)

# Convert predictions back to original scale
predictions = scaler.inverse_transform(predictions)
y_test = scaler.inverse_transform(y_test)

# Visualize the results
plt.figure()
plt.plot(range(len(y_test)), y_test, label='Actual')
plt.plot(range(len(predictions)), predictions, label='Predicted')
plt.legend()
plt.xlabel('Time Step')
plt.ylabel('US_VIX')
plt.title('US_VIX Actual vs. Predicted')
plt.show()
