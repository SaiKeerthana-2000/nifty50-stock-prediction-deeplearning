import pandas as pd
import numpy as np
import os
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import load_model
from datetime import timedelta
import pandas_market_calendars as mcal  # For trading calendar

# Define paths
base_dir = os.path.dirname(__file__)
data_path = os.path.join(base_dir, "data", "stocks_data.csv")
model_path = os.path.join(base_dir, "models", "LSTM_model_best.h5")
predicted_data_path = os.path.join(base_dir, "data", "predicted_prices.csv")

def load_and_preprocess_data(data_path):
    """Loads stock data, filters the last 60 valid rows, and applies scaling."""
    try:
        data = pd.read_csv(data_path)
    except FileNotFoundError:
        raise FileNotFoundError(f"Error: {data_path} not found. Please ensure the file exists.")

    # Ensure 'Date' is in datetime format
    data['Date'] = pd.to_datetime(data['Date'])

    # Remove any rows with missing Close prices (or any non-stock rows like predictions)
    data = data[pd.notnull(data['Close'])]

    # Sort data by date to ensure it's in chronological order
    data = data.sort_values(by='Date')

    # Keep only the last 60 rows (for LSTM sequence input)
    data = data.tail(60)

    # Scale the 'Close' prices
    scaler = MinMaxScaler(feature_range=(0, 1))
    data['Scaled_Close'] = scaler.fit_transform(data[['Close']])

    return data, scaler


# Function to load trained LSTM model
def load_trained_model(model_path):
    """Loads the trained LSTM model."""
    try:
        model = load_model(model_path)
    except OSError:
        raise OSError(f"Error: Model file {model_path} not found. Train the model first.")

    return model

# Function to make the next day's prediction
def predict_next_closing_price():
    """Predicts the next day's closing price for the stock and stores it."""
    data, scaler = load_and_preprocess_data(data_path)
    model = load_trained_model(model_path)

    # Prepare the last 60-day sequence for prediction
    sequence_length = 60
    input_sequence = data['Scaled_Close'].values[-sequence_length:].reshape(1, sequence_length, 1)

    # Predict next day's closing price
    predicted_scaled = model.predict(input_sequence)

    # Inverse transform to get actual closing price
    predicted_price = scaler.inverse_transform([[predicted_scaled[0, 0]]])[0, 0]

    # Define margin for prediction range (±200)
    margin = 200
    prediction_range = (predicted_price - margin, predicted_price + margin)

    # Determine next valid trading day
    last_date = data['Date'].iloc[-1]

    # **Non-Trading Days (Holidays & Weekends)**
    holidays = {
        '2025-01-26', '2025-02-26', '2025-03-14', '2025-03-31', '2025-04-06', '2025-04-10',
        '2025-04-14', '2025-04-18', '2025-05-01', '2025-06-07', '2025-07-06', '2025-08-15',
        '2025-08-27', '2025-10-02', '2025-10-21', '2025-10-22', '2025-11-05', '2025-12-25'
    }
    holidays = set(pd.to_datetime(list(holidays)))  # Convert to datetime format

    predicted_date = last_date + timedelta(days=1)

    while predicted_date.weekday() >= 5 or predicted_date in holidays:  # Skip weekends & holidays
        predicted_date += timedelta(days=1)

    # **NEW: Save Prediction to CSV**
    new_prediction = pd.DataFrame({"Date": [predicted_date.strftime('%Y-%m-%d')], "Predicted_Price": [predicted_price]})

    # If file exists, append; otherwise, create a new file
    if os.path.exists(predicted_data_path):
        existing_data = pd.read_csv(predicted_data_path)
        updated_data = pd.concat([existing_data, new_prediction]).drop_duplicates(subset=['Date'], keep='last')
    else:
        updated_data = new_prediction

    updated_data.to_csv(predicted_data_path, index=False)

    # Output the prediction and the range
    return predicted_date.strftime('%Y-%m-%d'), predicted_price, prediction_range

# If this script is run independently, print the next prediction
if __name__ == "__main__":
    next_date, predicted_price, prediction_range = predict_next_closing_price()
    print(f"Predicted closing price for {next_date}: {predicted_price:.2f}")
    print(f"Prediction range: {prediction_range[0]:.2f} to {prediction_range[1]:.2f}")

# Function to get the last 7 days' prices
def get_last_7_days_prices():
    """Fetches the last 7 days' actual and predicted closing prices."""
    # Load actual prices from stock data
    actual_data = pd.read_csv(data_path)
    actual_data['Date'] = pd.to_datetime(actual_data['Date'])
    actual_data = actual_data[['Date', 'Close']].sort_values(by="Date", ascending=False)

    # Load predicted prices
    if os.path.exists(predicted_data_path):
        predicted_data = pd.read_csv(predicted_data_path)
        predicted_data['Date'] = pd.to_datetime(predicted_data['Date'])
        predicted_data = predicted_data.sort_values(by="Date", ascending=False)
    else:
        predicted_data = pd.DataFrame(columns=['Date', 'Predicted_Price'])

    # Merge actual and predicted prices on Date
    merged_data = actual_data.merge(predicted_data, on='Date', how='left')

    # Keep only the last 7 days where we have actual prices
    merged_data = merged_data.sort_values(by="Date", ascending=False).head(7)

    return merged_data

if __name__ == "__main__":
    print(predict_next_closing_price())
