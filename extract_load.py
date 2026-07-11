import requests
import pandas as pd
from google.cloud import storage
from datetime import datetime, timedelta
import time

# --- NEW: Calculate the date range for the last 7 days ---
today = datetime.now().strftime('%Y-%m-%d')
last_week = (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d')

print(f"Starting incremental pull for dates: {last_week} to {today}")

# 1. Fetch data from UCDP API
TOKEN = # public token for UCDP API
headers = {"x-ucdp-access-token": TOKEN}
url = "https://ucdpapi.pcr.uu.se/api/gedevents/26.1"

all_new_events = []
page = 1
pagesize = 1000 # Keep at 1000 for efficiency

# The Pagination Loop for weekly data
while True:
    # IMPORTANT: You must check the UCDP API documentation for the exact names 
    # of their date filters. I am using 'StartDate' and 'EndDate' as common examples.
    params = {
        "pagesize": pagesize, 
        "page": page,
        "StartDate": last_week, 
        "EndDate": today        
    }
    
    response = requests.get(url, headers=headers, params=params)
    
    if response.status_code != 200:
        print(f"Error fetching data on page {page}: {response.status_code}")
        break
        
    data = response.json()
    results = data.get("Result", [])
    
    if len(results) == 0:
        print("Finished pulling this week's events!")
        break
        
    all_new_events.extend(results)
    print(f"Downloaded page {page} (Total new rows: {len(all_new_events)})")
    page += 1
    time.sleep(0.5)


# Only proceed with saving/uploading if the API actually found new data this week
if len(all_new_events) > 0:
    
    # 2. Convert to DataFrame and save with a DYNAMIC filename
    filename = f"GEDEvent_v26_{today}.csv"
    
    df = pd.DataFrame(all_new_events)

# Create a new column with the exact date and time the script is running
    df['_loaded_at'] = pd.Timestamp.now()

    df.to_csv(filename, index=False)
    print(f"Saved {len(all_new_events)} rows to {filename}")

    # 3. Upload to Google Cloud Storage as a NEW file
    print("Uploading to Google Cloud Data Lake...")
    client = storage.Client()
    bucket = client.bucket('ucdp_raw_data')
    
    # We use the dynamic filename here so it creates a brand new file in the bucket 
    # instead of overwriting the historical one!
    blob = bucket.blob(filename) 
    blob.upload_from_filename(filename)

    print(f"Success! {filename} securely uploaded to Data Lake.")
else:
    print("No new events found for the past 7 days. Nothing to upload.")
