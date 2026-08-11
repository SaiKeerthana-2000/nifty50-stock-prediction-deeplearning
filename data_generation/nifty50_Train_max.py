import yfinance as yf
import os

# Define the Nifty 50 index ticker
ticker = "^NSEI"  # Nifty 50 index symbol on Yahoo Finance

# Fetch historical data
data = yf.download(ticker, start="1990-01-01", end="2024-12-31")

# Save to CSV
print(data.head())

# Save to CSV
output_file = os.path.join("..", "data", "Nifty50_Train_max.csv")
data.to_csv(output_file)
print("Data saved to nifty50_data.csv.")