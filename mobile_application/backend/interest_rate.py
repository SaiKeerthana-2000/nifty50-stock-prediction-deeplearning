import requests
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = os.path.dirname(__file__)

# API URL for Real Interest Rate in India (set INTEREST_RATE_API_URL in your .env file)
url = os.getenv(
    "INTEREST_RATE_API_URL",
    "https://api.worldbank.org/v2/country/IN/indicator/FR.INR.RINR?format=json&per_page=100",
)

# File Path to Save Interest Rate Data (resolved relative to this script)
csv_file_path = os.path.join(BASE_DIR, "data", "interest_rate_data.csv")

def fetch_interest_rate():
    """Fetch Real Interest Rate Data from World Bank API and Save to CSV."""
    try:
        # 📡 Fetch data from World Bank API
        response = requests.get(url)

        # ✅ Check for successful response
        if response.status_code == 200:
            data = response.json()

            # Check if valid data is returned
            if len(data) > 1 and isinstance(data[1], list):
                interest_rate_data = []

                # 🔁 Loop through available data and store non-null values
                for record in data[1]:
                    if record['value'] is not None:
                        year = int(record['date'])  # Extract year as integer
                        interest_rate = round(float(record['value']), 4)  # Round to 4 decimal places
                        interest_rate_data.append({"Year": year, "Interest_Rate": interest_rate})

                # 📊 Create DataFrame and Save to CSV
                if interest_rate_data:
                    df = pd.DataFrame(interest_rate_data)

                    # ✅ Create "data" folder if not exists
                    os.makedirs(os.path.dirname(csv_file_path), exist_ok=True)

                    # ✅ Save data to CSV
                    df.to_csv(csv_file_path, index=False)
                    print(f"✅ Interest rate data saved to {csv_file_path}")
                else:
                    print("⚠️ No valid interest rate data found.")
            else:
                print("❌ Invalid response format from API.")
        else:
            print(f"❌ Failed to fetch data. Status Code: {response.status_code}")

    except Exception as e:
        print(f"❌ Error fetching interest rate data: {str(e)}")


# ✅ Run the function only if executed directly
if __name__ == "__main__":
    fetch_interest_rate()
