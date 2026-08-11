import requests
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = os.path.dirname(__file__)

# World Bank API is public and needs no key. INFLATION_API_URL can still be overridden via .env.
INFLATION_API_URL = os.getenv(
    "INFLATION_API_URL",
    "https://api.worldbank.org/v2/country/IN/indicator/FP.CPI.TOTL.ZG?format=json&per_page=100",
)


def fetch_and_save_inflation_data():
    # Data folder resolved relative to this script, not the working directory
    data_folder = os.path.join(BASE_DIR, "data")
    os.makedirs(data_folder, exist_ok=True)

    # Fetch data from World Bank API
    try:
        response = requests.get(INFLATION_API_URL)

        if response.status_code == 200:
            data = response.json()

            # Check if valid data is returned
            if len(data) > 1 and isinstance(data[1], list):
                inflation_data = []

                # Loop through all available data and store non-null values
                for record in data[1]:
                    if record['value'] is not None:
                        year = int(record['date'])
                        inflation_rate = round(float(record['value']), 2)
                        inflation_data.append({"Year": year, "Inflation_Rate": inflation_rate})

                # Create DataFrame and Save to CSV
                if inflation_data:
                    df = pd.DataFrame(inflation_data)

                    csv_file_path = os.path.join(data_folder, "inflation_data.csv")
                    df.to_csv(csv_file_path, index=False)

                    print(f"✅ Inflation rate data saved to {csv_file_path}")
                    print(df.head())  # Show top 5 rows for confirmation
                else:
                    print("⚠️ No valid inflation rate data found.")
            else:
                print("❌ Invalid response format.")
        else:
            print(f"❌ Failed to fetch data. Status Code: {response.status_code}")

    except Exception as e:
        print(f"❌ Error fetching inflation rate: {str(e)}")


# Run the function only when this script is executed directly
if __name__ == "__main__":
    fetch_and_save_inflation_data()
