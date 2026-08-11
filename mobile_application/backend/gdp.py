import requests
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = os.path.dirname(__file__)

# World Bank API is public and needs no key. GDP.API_URL can still be overridden via .env.
GDP_API_URL = os.getenv(
    "GDP_API_URL",
    "https://api.worldbank.org/v2/country/IN/indicator/NY.GDP.MKTP.CD?format=json&per_page=100",
)


def fetch_and_save_gdp_data():
    # Fetch data from World Bank API
    try:
        response = requests.get(GDP_API_URL)

        if response.status_code == 200:
            data = response.json()

            # Check if valid data is returned
            if len(data) > 1 and isinstance(data[1], list):
                gdp_data = []

                # Loop through all available data and store non-null values
                for record in data[1]:
                    if record['value'] is not None:
                        year = record['date']
                        gdp_value = round(float(record['value']), 2)
                        gdp_data.append({"Year": year, "GDP": gdp_value})

                # Create DataFrame and Save to CSV
                if gdp_data:
                    df = pd.DataFrame(gdp_data)

                    # Data folder resolved relative to this script, not the working directory
                    data_folder = os.path.join(BASE_DIR, "data")
                    os.makedirs(data_folder, exist_ok=True)

                    csv_file_path = os.path.join(data_folder, "gdp_data.csv")
                    df.to_csv(csv_file_path, index=False)

                    print(f"✅ GDP data saved to {csv_file_path}")
                    print(df.head())  # Show top 5 rows for confirmation
                else:
                    print("⚠️ No valid GDP data found.")
            else:
                print("❌ Invalid response format.")
        else:
            print(f"❌ Failed to fetch data. Status Code: {response.status_code}")

    except Exception as e:
        print(f"❌ Error fetching GDP data: {str(e)}")


# Only runs when this file is executed directly (e.g. `python gdp.py`) — NOT when
# another module does `from gdp import fetch_and_save_gdp_data`.
if __name__ == "__main__":
    fetch_and_save_gdp_data()
