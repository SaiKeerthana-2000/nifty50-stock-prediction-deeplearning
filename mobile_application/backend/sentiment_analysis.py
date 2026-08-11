import os
import pandas as pd
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch.nn.functional as F
import nltk

# Download required NLTK resources
nltk.download('punkt')
nltk.download('stopwords')

# Define paths relative to this script's own location, not the working directory
base_dir = os.path.dirname(__file__)
news_data_path = os.path.join(base_dir, "data", "news_data.csv")  # News data CSV
sentiment_output_path = os.path.join(base_dir, "data", "news_sentiment_results.csv")  # Sentiment results
market_sentiment_path = os.path.join(base_dir, "data", "market_sentiment.csv")  # Overall sentiment tracking

# Load FinBERT model and tokenizer once, at import time (this is fine to keep at
# module level — it's just loading weights into memory, not touching any files).
MODEL_NAME = "ProsusAI/finbert"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME)

# ====================== HELPER FUNCTION ======================


def predict_sentiment(text):
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True, max_length=512)
    with torch.no_grad():
        outputs = model(**inputs)
        probs = F.softmax(outputs.logits, dim=-1)

    sentiment_labels = ["negative", "neutral", "positive"]
    sentiment = sentiment_labels[torch.argmax(probs)]
    sentiment_score = probs[0][torch.argmax(probs)].item()

    return sentiment, sentiment_score


# ====================== EXTERNAL SENTIMENT FUNCTION ======================

def analyze_sentiment(text):
    """Used by app.py for a single piece of text (e.g. one headline)."""
    sentiment, sentiment_score = predict_sentiment(text)
    return sentiment, sentiment_score


# ====================== BATCH JOB ======================

def run_batch_sentiment_analysis():
    """Score every row in news_data.csv with FinBERT and update the sentiment CSVs.

    This is a standalone batch job — it requires news_data.csv to already exist
    (run news_data.py's fetch_latest_news() first). It only runs when this file
    is executed directly (`python sentiment_analysis.py`); importing this module
    elsewhere does NOT trigger it, so app.py can safely import analyze_sentiment
    without needing news_data.csv to exist yet.
    """
    df = pd.read_csv(news_data_path)
    df["text"] = df["title"].fillna('') + " " + df["description"].fillna('')

    df["Sentiment"], df["Sentiment_Score"] = zip(*df["text"].map(predict_sentiment))

    sentiment_counts = df["Sentiment"].value_counts()
    overall_sentiment = sentiment_counts.idxmax()
    overall_sentiment_score = df[df["Sentiment"] == overall_sentiment]["Sentiment_Score"].mean()

    df.to_csv(sentiment_output_path, index=False)

    # ---- Market sentiment summary for tomorrow's date ----
    tomorrow_date = (pd.Timestamp.today() + pd.Timedelta(days=1)).strftime('%Y-%m-%d')
    sentiment_summary = pd.DataFrame([{
        "Date": tomorrow_date,
        "Overall_Sentiment": overall_sentiment,
        "Sentiment_Score": round(overall_sentiment_score, 4),
        "Negative_Count": sentiment_counts.get("negative", 0),
        "Neutral_Count": sentiment_counts.get("neutral", 0),
        "Positive_Count": sentiment_counts.get("positive", 0),
    }])

    if os.path.exists(market_sentiment_path):
        market_df = pd.read_csv(market_sentiment_path)

        if tomorrow_date in market_df["Date"].values:
            market_df.loc[market_df["Date"] == tomorrow_date, "Overall_Sentiment"] = overall_sentiment
            market_df.loc[market_df["Date"] == tomorrow_date, "Sentiment_Score"] = round(overall_sentiment_score, 4)
            market_df.loc[market_df["Date"] == tomorrow_date, "Negative_Count"] = sentiment_counts.get("negative", 0)
            market_df.loc[market_df["Date"] == tomorrow_date, "Neutral_Count"] = sentiment_counts.get("neutral", 0)
            market_df.loc[market_df["Date"] == tomorrow_date, "Positive_Count"] = sentiment_counts.get("positive", 0)
        else:
            market_df = pd.concat([market_df, sentiment_summary], ignore_index=True)
    else:
        market_df = sentiment_summary

    market_df.drop_duplicates(subset="Date", keep="last", inplace=True)
    market_df.dropna(how="all", inplace=True)
    market_df.to_csv(market_sentiment_path, index=False)

    print(df[["title", "Sentiment", "Sentiment_Score"]].head())
    print("\nSentiment Distribution:")
    print(sentiment_counts)
    print(f"\n✅ Overall Market Sentiment: {overall_sentiment} ({round(overall_sentiment_score, 4)})")


if __name__ == "__main__":
    run_batch_sentiment_analysis()
