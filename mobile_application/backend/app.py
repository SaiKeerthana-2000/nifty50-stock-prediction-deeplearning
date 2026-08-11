from flask import Flask, jsonify
from news_data import fetch_latest_news, fetch_and_save_news_data
from sentiment_analysis import analyze_sentiment, run_batch_sentiment_analysis  # Import sentiment analysis functions
from model import predict_next_closing_price
from stocks_data import fetch_and_save_stock_data  # Fetch stock data
import pandas as pd
import os
from flask_cors import CORS  # Enable CORS
from fgi_model import calculate_fgi_with_prediction  # Import updated FGI function
from fgi_data import fetch_and_save_fgi_data  # Import updated FGI data function
from interest_rate import fetch_interest_rate
from gdp import fetch_and_save_gdp_data
from inflation_rate import fetch_and_save_inflation_data
from stock_recommendations import load_latest_data, generate_recommendation, save_recommendation

from flask import Flask, request, jsonify
from flask_cors import CORS
import pymysql
import os
from dotenv import load_dotenv

# Load MySQL credentials from .env
load_dotenv()

app = Flask(__name__)
CORS(app)  # ✅ Enable CORS for frontend requests

# ✅ Database Connection Function
def get_db_connection():
    return pymysql.connect(
        host=os.getenv("DB_HOST", "localhost"),
        user=os.getenv("DB_USER", "your_user"),
        password=os.getenv("DB_PASSWORD", "your_password"),
        database=os.getenv("DB_NAME", "your_database"),
        cursorclass=pymysql.cursors.DictCursor  # ✅ Returns results as dictionary
    )

# ✅ Register User
@app.route('/register', methods=['POST'])
def register_user():
    try:
        data = request.get_json()
        name = data['name']
        email = data['email']
        username = data['username']
        phone = data['phone']
        password = data['password']
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO users (name, email, username, password, phone) VALUES (%s, %s, %s, %s, %s)",
            (name, email, username, password, phone)
        )
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"message": "User registered successfully!"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Login User
@app.route('/login', methods=['POST'])
def login_user():
    try:
        data = request.get_json()
        email = data['email']
        password = data['password']

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "SELECT id, name, email, username, phone FROM users WHERE email = %s AND password = %s",
            (email, password)
        )
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user:
            return jsonify({"success": True, "user": user})
        else:
            return jsonify({"success": False, "message": "Invalid credentials"}), 401

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Get User by ID
@app.route('/user/<int:id>', methods=['GET'])
def get_user(id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, name, email, username, phone FROM users WHERE id = %s", (id,))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user:
            return jsonify(user)
        else:
            return jsonify({"message": "User not found"}), 404

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ✅ Logout User (Dummy API - Needs JWT Implementation)
@app.route('/logout', methods=['POST'])
def logout():
    return jsonify({"message": "User logged out successfully!"})



# Define file paths
base_dir = os.path.dirname(__file__)
data_path = os.path.join(base_dir, "data", "stocks_data.csv")  # Actual stock prices
predictions_path = os.path.join(base_dir, "data", "predicted_prices.csv")  # Predicted prices
sentiment_results_path = os.path.join(base_dir, "data", "news_sentiment_results.csv")  # Sentiment scores
fgi_path = os.path.join(base_dir, "data", "fgi_data_with_fgi.csv")  # Updated FGI data


# ✅ Fetch latest news and run sentiment analysis before starting Flask
print("[✔] Fetching latest news...")
fetch_and_save_news_data()
print("[✔] News data updated successfully.")

print("[✔] Running sentiment analysis on latest news...")
run_batch_sentiment_analysis()
print("[✔] Sentiment analysis updated successfully.")

# ✅ Fetch and save latest FGI data before starting Flask
print("[✔] Fetching and saving latest FGI data...")
fetch_and_save_fgi_data()
print("[✔] FGI data updated successfully.")

# ✅ Fetch latest interest rate data before running FGI calculations
fetch_interest_rate()
fetch_and_save_gdp_data()
fetch_and_save_inflation_data()

# ✅ Calculate and save FGI with tomorrow's prediction
print("[✔] Calculating FGI with tomorrow's prediction...")
calculate_fgi_with_prediction()
print("[✔] FGI calculated successfully with prediction.")

# ✅ Ensure stock data updates BEFORE using it in the model
print("[✔] Fetching latest stock data...")
fetch_and_save_stock_data()  # Runs stocks_data.py first
print("[✔] Stock data updated successfully.")




# ====================== HELPER FUNCTIONS ======================

# Function to fetch and process stock news with sentiment analysis
def get_news_with_sentiment():
    try:
        news_list = fetch_latest_news()  # Fetch latest news

        # Add sentiment analysis
        for news in news_list:
            news["Sentiment"], news["Sentiment_Score"] = analyze_sentiment(news["title"])

        return news_list  # Return as JSON
    except Exception as e:
        return {"error": f"Failed to fetch news: {str(e)}"}

# Function to fetch latest stock data
def get_latest_stock_data():
    try:
        stock_data = fetch_and_save_stock_data()  # Fetch updated stock data
        if stock_data is None:
            return {"error": "Stock data unavailable"}
        return stock_data  # JSON format
    except Exception as e:
        return {"error": f"Failed to fetch stock data: {str(e)}"}

# Function to fetch latest 5 news headlines with sentiment scores
def get_latest_news():
    try:
        if os.path.exists(sentiment_results_path):
            # Read sentiment results data
            sentiment_df = pd.read_csv(sentiment_results_path)

            # Select required columns
            selected_columns = ['title', 'source', 'publishedAt', 'description', 'url', 'Sentiment']
            news_df = sentiment_df[selected_columns]

            # Sort by published date (latest first) and get the top 5 news articles
            latest_news = news_df.sort_values(by='publishedAt', ascending=False).head(5)

            # Convert to JSON format
            return latest_news.to_dict(orient="records")

        else:
            return {"error": "Sentiment results file not found"}

    except Exception as e:
        return {"error": f"Failed to fetch latest news: {str(e)}"}


# ====================== API ROUTES ======================

# API to get overall sentiment and predicted stock price
# API to get overall sentiment and predicted stock price
# API to get overall sentiment and predicted stock price
@app.route('/predict', methods=['GET'])
def get_prediction():
    try:
        # ✅ Load the latest stock, prediction, sentiment, and FGI data before generating recommendation
        from stock_recommendations import load_latest_data  # Import the function

        latest_data = load_latest_data()  # CALL to load latest data
        
        # Use analyze_sentiment with a placeholder text to get the overall market sentiment
        overall_sentiment, _ = analyze_sentiment("Market analysis today")  # Dummy text
        
        # Get the predicted stock price and the range
        predicted_date, predicted_price, prediction_range = predict_next_closing_price()

        # Save prediction to CSV
        save_prediction(predicted_date, predicted_price)

        # ✅ Generate stock recommendation based on the latest data
        recommendation_result = generate_recommendation()  # CALL to generate recommendation
        save_recommendation(recommendation_result)  # CALL to save recommendation to CSV

        # ✅ Return all results including recommendation
        return jsonify({
            "Date": predicted_date,
            "Predicted_Price": predicted_price,
            "Prediction_Range": prediction_range,
            "Overall_Market_Sentiment": overall_sentiment,
            "Today_Close" : recommendation_result["Today_Close"],
            "FGI Score": recommendation_result["FGI_Score"],
            "FGI_Sentiment": recommendation_result["FGI_Sentiment"],
            "Recommendation": recommendation_result["Recommendation"]
            
        })
    except Exception as e:
        return jsonify({"error": f"Failed to get prediction, sentiment, or recommendation: {str(e)}"})


# API to get latest stock data
@app.route('/stock_data', methods=['GET'])
def stock_data():
    try:
        stock_data = get_latest_stock_data()
        return jsonify(stock_data)
    except Exception as e:
        return jsonify({"error": f"Failed to fetch stock data: {str(e)}"})

# API to get latest news with sentiment scores
@app.route('/latest_news', methods=['GET'])
def latest_news():
    try:
        news_data = get_latest_news()
        return jsonify(news_data)
    except Exception as e:
        return jsonify({"error": f"Failed to fetch latest news: {str(e)}"})

# API to fetch the past 7 days of actual vs predicted stock prices
@app.route('/past_predictions', methods=['GET'])
def past_predictions():
    try:
        # Load actual stock data
        if os.path.exists(data_path):
            actual_data = pd.read_csv(data_path)
            actual_data['Date'] = pd.to_datetime(actual_data['Date'])
        else:
            return jsonify({"error": "Actual stock data file not found"})

        # Load predicted stock data
        if os.path.exists(predictions_path):
            predicted_data = pd.read_csv(predictions_path)
            predicted_data['Date'] = pd.to_datetime(predicted_data['Date'])
        else:
            return jsonify({"error": "Predicted stock data file not found"})

        # Merge actual and predicted data
        merged_data = pd.merge(actual_data, predicted_data, on="Date", how="inner")
        merged_data = merged_data[['Date', 'Close', 'Predicted_Price']]

        # Format Date column to 'yyyy/MM/dd'
        merged_data['Date'] = merged_data['Date'].dt.strftime('%Y/%m/%d')

        # Get last 7 days of actual vs predicted prices
        last_7_days = merged_data.sort_values("Date", ascending=False).head(7)

        # Convert to JSON and return
        result = last_7_days.to_dict(orient="records")
        return jsonify(result)

    except Exception as e:
        return jsonify({"error": f"Failed to fetch past predictions: {str(e)}"})

# API to get the latest 5 days of FGI data
@app.route('/fgi_data', methods=['GET'])
def get_fgi_data():
    """Fetch the last 7 days of FGI data, excluding tomorrow's value."""
    try:
        if os.path.exists(fgi_path):
            # Load FGI data
            fgi_data = pd.read_csv(fgi_path)
            fgi_data['Date'] = pd.to_datetime(fgi_data['Date']).dt.strftime('%Y-%m-%d')

            # Exclude the last row (tomorrow's FGI value)
            past_7_days_fgi = fgi_data.iloc[-8:-1][['Date', 'FGI_Normalized', 'Market_Sentiment']]

            # Convert to dictionary format
            return jsonify(past_7_days_fgi.to_dict(orient="records"))
        else:
            return jsonify({"error": "FGI data file not found"})

    except Exception as e:
        return jsonify({"error": f"Failed to fetch FGI data: {str(e)}"})
    
@app.route('/fgi_tomorrow', methods=['GET'])
def get_fgi_tomorrow():
    """Fetch only tomorrow's FGI (Fear & Greed Index) value."""
    try:
        if os.path.exists(fgi_path):
            # Load FGI data
            fgi_data = pd.read_csv(fgi_path)
            fgi_data['Date'] = pd.to_datetime(fgi_data['Date']).dt.strftime('%Y-%m-%d')

            # Get the last row (tomorrow's FGI value)
            tomorrow_fgi = fgi_data.iloc[-1][['Date', 'FGI_Normalized', 'Market_Sentiment']].to_dict()

            return jsonify(tomorrow_fgi)
        else:
            return jsonify({"error": "FGI data file not found"})

    except Exception as e:
        return jsonify({"error": f"Failed to fetch tomorrow's FGI data: {str(e)}"})
import pandas as pd

# Function to load past recommendations from CSV
def load_past_recommendations():
    try:
        recommendation_path = os.path.join(base_dir, "data", "recommendations.csv")
        
        # Ensure the file exists
        if os.path.exists(recommendation_path):
            recommendations_df = pd.read_csv(recommendation_path)
            recommendations_df['Date'] = pd.to_datetime(recommendations_df['Date']).dt.strftime('%Y/%m/%d')  # Ensure Date is in datetime format
            
            # Sort by Date in descending order to get the most recent first
            recommendations_df = recommendations_df.sort_values(by="Date", ascending=False)

            return recommendations_df
        else:
            return {"error": "Recommendation file not found"}
    except Exception as e:
        return {"error": f"Failed to load recommendation data: {str(e)}"}

# API to get past stock recommendations (excluding the most recent one)
@app.route('/past_recommendations', methods=['GET'])
def past_recommendations():
    try:
        # Load past recommendations from CSV
        recommendations_df = load_past_recommendations()
        
        if isinstance(recommendations_df, dict) and 'error' in recommendations_df:
            return jsonify(recommendations_df)
        
        # Exclude the most recent recommendation (i.e., exclude the last row)
        recommendations_df = recommendations_df.iloc[1:]

        # Convert to JSON format
        result = recommendations_df.to_dict(orient="records")
        return jsonify(result)
    
    except Exception as e:
        return jsonify({"error": f"Failed to fetch past recommendations: {str(e)}"}) 





# Function to save predictions in a CSV file
def save_prediction(date, predicted_price):
    """Save the predicted stock price to a CSV file."""
    try:
        new_data = pd.DataFrame({"Date": [date], "Predicted_Price": [predicted_price]})

        if os.path.exists(predictions_path):
            existing_data = pd.read_csv(predictions_path)
            updated_data = pd.concat([existing_data, new_data], ignore_index=True)
        else:
            updated_data = new_data

        # Save to CSV
        updated_data.to_csv(predictions_path, index=False)
    except Exception as e:
        print(f"Error saving prediction: {e}")


# ====================== RUN FLASK APP ======================
if __name__ == '__main__':
    print("[✔] Flask server is running...")
    app.run(host='0.0.0.0', port=5000, debug=False)  # Allows external connections
