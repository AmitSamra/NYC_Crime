from sodapy import Socrata
import pandas as pd
from pymongo import MongoClient
from dotenv import load_dotenv
import os
import csv

dotenv_local_path = '.env'
load_dotenv(dotenv_path=dotenv_local_path, verbose=True)

# ------------------------------------------------------------------------------------------

# Connect to Socrata API

client=Socrata(
"data.cityofnewyork.us",
os.environ.get("NYC_token"),
username=os.environ.get("NYC_username"),
password=os.environ.get("NYC_password")
)

# ------------------------------------------------------------------------------------------

# Save results from API in CSV by year

start_year=2006
end_year=2019

for i in range(start_year, end_year+1, 1):
    results = client.get("8h9b-rp9u", where="arrest_date between "+"'"+str(i)+"-01-01'"+" and "+"'"+str(i)+"-12-31'", limit=10000000)
    results_df = pd.DataFrame.from_records(results)
    results_df.to_csv(f"./raw_data/{i}.csv", index=False)

