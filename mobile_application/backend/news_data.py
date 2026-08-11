import requests
import csv
import os
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, "data")
NEWS_CSV_PATH = os.path.join(DATA_DIR, "news_data.csv")

# Set NEWS_API_KEY and NEWS_API_URL in your .env file (see .env.example)
API_KEY = os.getenv("NEWS_API_KEY", "")
API_URL = os.getenv("NEWS_API_URL", "https://newsapi.org/v2/everything")


def fetch_and_save_news_data(max_articles=500):
    """Fetch NIFTY 50-related news from NewsAPI and overwrite news_data.csv.

    This makes real network calls and consumes NewsAPI quota, so it only runs when
    called explicitly (or when this file is executed directly) — NOT just from
    `from news_data import fetch_latest_news` in app.py.
    """
    os.makedirs(DATA_DIR, exist_ok=True)

    params = {
        "q": "Nifty50 OR #Nifty50 OR NSE OR Nifty",
        "sortBy": "publishedAt",
        "apiKey": API_KEY,
        "language": "en",
        "pageSize": 100,
    }

    all_articles = []
    unique_urls = set()
    current_page = 1

    while len(all_articles) < max_articles:
        params["page"] = current_page
        response = requests.get(API_URL, params=params)

        if response.status_code == 200:
            articles = response.json().get("articles", [])
            if not articles:
                break

            for article in articles:
                if article["url"] not in unique_urls:
                    all_articles.append(article)
                    unique_urls.add(article["url"])

            if len(all_articles) >= max_articles:
                break

            current_page += 1
        else:
            print(f"Error: {response.status_code}")
            print(f"Response: {response.text}")
            break

    new_articles = [
        {
            "title": article["title"],
            "source": article["source"]["name"],
            "publishedAt": article["publishedAt"],
            "description": article["description"],
            "url": article["url"],
        }
        for article in all_articles
    ]

    new_articles.sort(key=lambda x: datetime.strptime(x["publishedAt"], "%Y-%m-%dT%H:%M:%SZ"), reverse=True)

    with open(NEWS_CSV_PATH, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=["title", "source", "publishedAt", "description", "url"])
        writer.writeheader()
        writer.writerows(new_articles)

    print(f"Recent news articles related to Nifty50 have been saved to {NEWS_CSV_PATH}")
    print(f"Total articles saved: {len(new_articles)}")
    return new_articles


def fetch_latest_news():
    """Read the already-saved news_data.csv (does not hit the network).
    Used by app.py's /latest_news route. Run fetch_and_save_news_data() first
    (or on a schedule) to keep this file fresh."""
    try:
        with open(NEWS_CSV_PATH, mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            news_list = [row for row in reader]
        return news_list
    except Exception as e:
        print(f"Error reading news data: {e}")
        return []


if __name__ == "__main__":
    fetch_and_save_news_data()
