import pandas as pd
import numpy as np
import os
from datetime import datetime, timedelta

BASE_DIR = os.path.dirname(__file__)


def calculate_fgi_with_prediction():
    # 📂 Correct File Paths (resolved relative to this script, not the working directory)
    fgi_file_path = os.path.join(BASE_DIR, "data", "fgi_data.csv")  # 257 days of historical data
    predicted_file_path = os.path.join(BASE_DIR, "data", "predicted_prices.csv")  # Predicted value for tomorrow
    interest_rate_file_path = os.path.join(BASE_DIR, "data", "interest_rate_data.csv")  # Interest rate data
    gdp_file_path = os.path.join(BASE_DIR, "data", "gdp_data.csv")  # GDP data for India
    inflation_file_path = os.path.join(BASE_DIR, "data", "inflation_data.csv")  # Inflation rate data

    # ✅ 1. Load Nifty 50 data from fgi_data.csv
    data = pd.read_csv(fgi_file_path)

    # Ensure Date column is in datetime format and keep only date
    data['Date'] = pd.to_datetime(data['Date']).dt.date

    # Sort data by Date to ensure correct order
    data = data.sort_values(by='Date', ascending=True).reset_index(drop=True)

    # ✅ 2. Load tomorrow's predicted price from predicted_prices.csv
    predicted_data = pd.read_csv(predicted_file_path)

    # Get tomorrow's predicted Close value
    tomorrow_predicted_row = predicted_data.iloc[-1]  # ✅ Get the last row of predicted data
    tomorrow_predicted_date = pd.to_datetime(tomorrow_predicted_row['Date']).strftime('%Y-%m-%d')
    tomorrow_predicted_close = tomorrow_predicted_row['Predicted_Price']

    # ✅ 3. Append tomorrow's predicted value to fgi_data.csv
    new_row = pd.DataFrame({'Date': [tomorrow_predicted_date],
                            'Close': [tomorrow_predicted_close]})

    # Add predicted row to data for FGI calculation
    data = pd.concat([data, new_row], ignore_index=True)

    # ✅ 4. Market Momentum: SMA & EMA Crossover
    data['SMA_50'] = data['Close'].rolling(window=50).mean()  # 50-Day SMA
    data['SMA_200'] = data['Close'].rolling(window=200).mean()  # 200-Day SMA
    data['EMA_50'] = data['Close'].ewm(span=50, adjust=False).mean()  # 50-Day EMA
    data['EMA_200'] = data['Close'].ewm(span=200, adjust=False).mean()  # 200-Day EMA

    # ✅ 5. Volatility Indicator: ATR (Average True Range)
    def calculate_true_range(row, prev_close):
        # Handle missing High/Low values for predicted data
        if pd.isnull(row['High-Low']) or row['High-Low'] == 0:
            row['High-Low'] = abs(prev_close * 1.01 - prev_close * 0.99)  # Estimate 1% range
            row['High-Close'] = abs(prev_close * 1.01 - prev_close)
            row['Low-Close'] = abs(prev_close * 0.99 - prev_close)
        row['True_Range'] = max(row['High-Low'], row['High-Close'], row['Low-Close'])
        return row['True_Range']

    data['High-Low'] = 0.0
    data['High-Close'] = 0.0
    data['Low-Close'] = 0.0
    data['True_Range'] = 0.0

    for i in range(1, len(data)):
        prev_close = data.loc[i - 1, 'Close']
        data.loc[i, 'True_Range'] = calculate_true_range(data.loc[i], prev_close)

    data['ATR_14'] = data['True_Range'].rolling(window=14).mean()

    # ✅ 6. Relative Strength Index (RSI)
    def calculate_rsi(series, period=14):
        delta = series.diff()
        gain = delta.where(delta > 0, 0)
        loss = -delta.where(delta < 0, 0)

        avg_gain = gain.rolling(window=period, min_periods=1).mean()
        avg_loss = loss.rolling(window=period, min_periods=1).mean()

        rs = avg_gain / avg_loss
        rsi = 100 - (100 / (1 + rs))
        return rsi

    data['RSI_14'] = calculate_rsi(data['Close'], period=14)

    # ✅ 7. Load and Integrate Interest Rate Data
    interest_data = pd.read_csv(interest_rate_file_path)
    interest_data['Year'] = interest_data['Year'].astype(int)
    latest_interest_rate = interest_data.loc[interest_data['Year'].idxmax()]['Interest_Rate']

    # Add Interest Rate as a new column
    data['Interest_Rate'] = latest_interest_rate

    # ✅ 8. Load and Integrate GDP Data
    gdp_data = pd.read_csv(gdp_file_path)
    gdp_data['Year'] = gdp_data['Year'].astype(int)

    # Get the most recent available GDP value (handle data only up to 2023)
    current_year = datetime.now().year
    if current_year > 2023:
        latest_gdp_value = gdp_data.loc[gdp_data['Year'] == 2023, 'GDP'].values[0]
    else:
        latest_gdp_value = gdp_data.loc[gdp_data['Year'] == current_year, 'GDP'].values[0]

    # ✅ 9. Load and Integrate Inflation Rate Data
    inflation_data = pd.read_csv(inflation_file_path)
    inflation_data['Year'] = inflation_data['Year'].astype(int)

    # Get the most recent available Inflation Rate
    if current_year > 2023:
        latest_inflation_rate = inflation_data.loc[inflation_data['Year'] == 2023, 'Inflation_Rate'].values[0]
    else:
        latest_inflation_rate = inflation_data.loc[inflation_data['Year'] == current_year, 'Inflation_Rate'].values[0]

    # ✅ Define GDP Score Based on Recent Growth
    def calculate_gdp_score(gdp):
        if gdp > 5e12:  # GDP above 5 Trillion USD → High growth
            return 1
        elif gdp > 3e12:  # GDP between 3 and 5 Trillion USD → Moderate growth
            return 0
        else:
            return -1  # Slow or negative growth → Fear

    gdp_score = calculate_gdp_score(latest_gdp_value)

    # ✅ Define Inflation Score Based on Rate
    def calculate_inflation_score(inflation):
        if inflation < 4:
            return 1  # Low inflation → Greed
        elif inflation <= 6:
            return 0  # Moderate inflation → Neutral
        else:
            return -1  # High inflation → Fear

    inflation_score = calculate_inflation_score(latest_inflation_rate)

    # ✅ 10. Fear & Greed Index Calculation
    # Define scoring ranges for different indicators
    def calculate_fgi(row):
        score = 0

        # 📈 Market Momentum Score
        if row['SMA_50'] > row['SMA_200']:
            score += 1  # Bullish Momentum (Greed)
        else:
            score -= 1  # Bearish Momentum (Fear)

        # 📉 RSI Score
        if row['RSI_14'] < 30:
            score -= 1  # Oversold (Fear)
        elif row['RSI_14'] > 70:
            score += 1  # Overbought (Greed)

        # 💡 Volatility Score (ATR as Proxy for VIX)
        if pd.notnull(row['ATR_14']) and row['ATR_14'] > data['ATR_14'].rolling(window=50).mean().iloc[row.name]:
            score -= 1  # Higher volatility (Fear)
        else:
            score += 1  # Lower volatility (Greed)

        # 📊 Interest Rate Score (Low rate → Greed, High rate → Fear)
        if row['Interest_Rate'] < 5:
            score += 1  # Low interest rate (Greed)
        elif row['Interest_Rate'] > 7:
            score -= 1  # High interest rate (Fear)

        # 📈 GDP Score (Add to FGI Score)
        score += gdp_score

        # 📊 Inflation Rate Score (Add to FGI Score)
        score += inflation_score

        return score

    # Apply FGI calculation
    data['FGI_Score'] = data.apply(calculate_fgi, axis=1)

    # ✅ 11. Normalize FGI Score to 0-100 Scale
    data['FGI_Normalized'] = ((data['FGI_Score'] - data['FGI_Score'].min()) /
                              (data['FGI_Score'].max() - data['FGI_Score'].min()) * 100)

    # ✅ 12. Classify Sentiment Based on FGI Score
    # ✅ 12. Classify Sentiment Based on FGI Score

    def classify_sentiment(score):
    	if score >= 75:
            return "🔴 Extreme Greed"  # Changed to Bright Red
    	elif score >= 50:
            return "🟢 Greed"  # Green for normal greed
    	elif score >= 25:
            return "🟠 Fear"  # Orange for moderate fear
    	else:
            return "🔵 Extreme Fear"  # Blue for extreme fear


    data['Market_Sentiment'] = data['FGI_Normalized'].apply(classify_sentiment)

    # ✅ 13. Save Updated Results Back to CSV
    data.to_csv(os.path.join(BASE_DIR, "data", "fgi_data_with_fgi.csv"), index=False)

    print("✅ Fear & Greed Index Calculated and Saved Successfully!")
    print(data[['Date', 'Close', 'FGI_Normalized', 'Market_Sentiment']].tail(7))


# Run the function when the script is executed
if __name__ == "__main__":
    calculate_fgi_with_prediction()
