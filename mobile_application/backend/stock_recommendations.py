import os
import pandas as pd

# Define file paths
base_dir = os.path.dirname(__file__)
stocks_data_path = os.path.join(base_dir, "data", "stocks_data.csv")  # Today's data
predicted_price_path = os.path.join(base_dir, "data", "predicted_prices.csv")  # Tomorrow's prediction
market_sentiment_path = os.path.join(base_dir, "data", "market_sentiment.csv")  # Tomorrow's sentiment
fgi_data_path = os.path.join(base_dir, "data", "fgi_data_with_fgi.csv")  # Tomorrow's FGI

def load_latest_data():
    """Load the latest row from each required CSV file."""
    stocks_df = pd.read_csv(stocks_data_path)
    predicted_df = pd.read_csv(predicted_price_path)
    market_sentiment_df = pd.read_csv(market_sentiment_path)
    fgi_df = pd.read_csv(fgi_data_path)

    return {
        "today_close": stocks_df.iloc[-1]["Close"],
        "predicted_price": predicted_df.iloc[-1]["Predicted_Price"],
        "market_sentiment": market_sentiment_df.iloc[-1]["Overall_Sentiment"],
        "fgi_score": fgi_df.iloc[-1]["FGI_Normalized"],
        "fgi_sentiment": fgi_df.iloc[-1]["Market_Sentiment"],
        "date": predicted_df.iloc[-1]["Date"]  # Using predicted data's date (tomorrow)
    }

def generate_recommendation():
    """Generate stock recommendation based on price prediction, FGI, and market sentiment."""
    data = load_latest_data()

    # Basic recommendation based on price change
    if data["predicted_price"] > data["today_close"]:
        recommendation = "BUY"
    elif data["predicted_price"] < data["today_close"]:
        recommendation = "SELL"
    else:
        recommendation = "HOLD"

    # Adjust recommendation based on FGI and market sentiment
    if recommendation == "BUY" and data["fgi_score"] > 75 and data["market_sentiment"] == "positive":
        recommendation = "STRONG BUY"
    elif recommendation == "SELL" and data["fgi_score"] <= 25 and data["market_sentiment"] == "negative":
        recommendation = "STRONG SELL"

    # Store the result in a dictionary
    result = {
        "Date": data["date"],
        "Today_Close": data["today_close"],
        "Predicted_Close": data["predicted_price"],
        "Market_Sentiment": data["market_sentiment"],
        "FGI_Score": data["fgi_score"],
        "FGI_Sentiment": data["fgi_sentiment"],
        "Recommendation": recommendation
    }

    return result

def save_recommendation(result):
    """Save the recommendation to a CSV file, updating if the date already exists."""
    recommendation_path = os.path.join(base_dir, "data", "recommendations.csv")

    new_entry = pd.DataFrame([result])

    if os.path.exists(recommendation_path):
        # Load existing data
        existing_df = pd.read_csv(recommendation_path)

        # Check if a row with the same date already exists
        if result["Date"] in existing_df["Date"].values:
            # Update the row with the new data
            existing_df.loc[existing_df["Date"] == result["Date"], result.keys()] = result.values()
        else:
            # Append new data if date does not exist
            existing_df = pd.concat([existing_df, new_entry], ignore_index=True)
    else:
        # Create a new file if it doesn't exist
        existing_df = new_entry

    # Save the updated data without duplicates
    existing_df.to_csv(recommendation_path, index=False)

if __name__ == "__main__":
    recommendation = generate_recommendation()
    print("\nFinal Recommendation:")
    for key, value in recommendation.items():
        print(f"{key}: {value}")

    save_recommendation(recommendation)
    print("\n✅ Recommendation saved successfully!")
