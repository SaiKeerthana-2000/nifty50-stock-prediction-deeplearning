import yfinance as yf
import pandas as pd
import os
from datetime import datetime, timedelta
import pandas_market_calendars as mcal 

# Set base directory and relative path to 'data' folder
basedir = os.path.dirname(__file__)
data_path = os.path.join(basedir, "data", "fgi_data.csv")

def fetch_and_save_fgi_data():

    # Define the ticker symbol for Nifty 50
    nifty50_ticker = "^NSEI"
    
    # Use today's date as the end date
    end_date = datetime.today()+timedelta(days=1)
    
    # Calculate the start date (100 days before the end date)
    start_date = end_date - timedelta(days=400)  # Giving enough buffer to find 30 trading days
    
    # Convert start and end dates to string format
    start_date_str = start_date.strftime('%Y-%m-%d')
    end_date_str = end_date.strftime('%Y-%m-%d')
    
    # Initialize the calendar for the Indian stock market (NSE)
    nse = mcal.get_calendar('NSE')
    
    # Get the list of all trading days between the start and end date
    valid_trading_days = nse.valid_days(start_date=start_date, end_date=end_date)
    
    # Ensure we are considering exactly 60 trading days
    valid_trading_days = valid_trading_days[-261:]  # Get the last 60 trading days
    
    # Fetch data for the 30 trading days
    nifty50_data = yf.download(nifty50_ticker, start=valid_trading_days[0].strftime('%Y-%m-%d'),
                               end=valid_trading_days[-1].strftime('%Y-%m-%d'), interval="1d")
    
    # Check if the data is fetched successfully
    if nifty50_data.empty:
        print(f"Data for {nifty50_ticker} is unavailable. Please verify the ticker symbol.")
    else:
        # Reset index to make the date a column
        nifty50_data.reset_index(inplace=True)
    
        # Ensure the date format is YYYY-MM-DD
        nifty50_data['Date'] = pd.to_datetime(nifty50_data['Date']).dt.strftime('%Y-%m-%d')
    
        # Check if the file already exists (same file we save to below)
        if os.path.exists(data_path):
            # Load existing data
            existing_data = pd.read_csv(data_path)
    
            # Combine the existing data with the new data, avoiding duplicates
            updated_data = pd.concat([existing_data, nifty50_data[~nifty50_data['Date'].isin(existing_data['Date'])]])
        else:
            # If the file does not exist, create it with the fetched data
            updated_data = nifty50_data
    
        # Save the updated data back to the file
        updated_data.to_csv(data_path, index=False)
    
        # Print the first few rows to verify
        print(updated_data.head())
        print(updated_data.tail()) 
        
    
    # Load the dataset into a pandas DataFrame
    data = pd.read_csv(data_path)
    
    # Remove the first row (index 0)
    data = data.drop(index=0)
    
    # Reset the index if you want to have a clean index after dropping the row
    data = data.reset_index(drop=True)
    
    # Optionally, save the modified DataFrame to a new CSV file
    data.to_csv(data_path, index=False)
    print("---------------------------------------------------------------------------")
    print(data.tail())

if __name__ == "__main__":
    print(fetch_and_save_fgi_data())
