import yfinance as yf
import pandas as pd
import os 

# Define the ticker symbol for Nifty 50
nifty50_symbol = '^NSEI'  # This is the Yahoo Finance ticker for Nifty 50

# Define the date range
start_date = '2014-12-01'
end_date = '2024-12-01'

# Fetch the data using yfinance
nifty50_data = yf.download(nifty50_symbol, start=start_date, end=end_date)

# Display the first few rows of the data
print(nifty50_data.head())

# Save the data to a CSV file
output_file = os.path.join("..", "data", "Nifty50_Train.csv")
nifty50_data.to_csv(output_file)
print(f"Data saved to {output_file}")
