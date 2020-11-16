from sodapy import Socrata
import pandas as pd
from pymongo import MongoClient
from dotenv import load_dotenv
import os
import csv
from sqlalchemy import create_engine

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

# Connect to MongoDB

mongo_client=MongoClient()
mongo_database = mongo_client['nyc_crime']
mongo_collection = mongo_database['arrests']

# ------------------------------------------------------------------------------------------

# Save results from API in CSV by year

start_year=2006
end_year=2019

for i in range(start_year, end_year+1, 1):
    results = client.get("8h9b-rp9u", where="arrest_date between "+"'"+str(i)+"-01-01'"+" and "+"'"+str(i)+"-12-31'", limit=10000000)
    results_df = pd.DataFrame.from_records(results)
    results_df.to_csv(f"./raw_data/{i}.csv", index=False)

# ------------------------------------------------------------------------------------------

# Connect to MySQL

engine = create_engine('mysql+pymysql://' + os.environ.get("MYSQL_USER") + ":" + os.environ.get("MYSQL_PASSWORD") + '@localhost:3306/nyc_crime')

start_year=2006
end_year=2006

for i in range(start_year, end_year+1, 1):
    results = client.get("8h9b-rp9u", where="arrest_date between "+"'"+str(i)+"-01-01'"+" and "+"'"+str(i)+"-01-31'", limit=10000000)
    results_df = pd.DataFrame.from_records(results)
    results_df = results_df.drop('lon_lat',1)
    results_df['arrest_key'] = results_df['arrest_key'].str.strip()
    results_df['arrest_key'] = results_df['arrest_key'].astype(int)
    results_df['arrest_date'] = pd.to_datetime(results_df['arrest_date'])
    results_df['arrest_precinct'] = results_df['arrest_precinct'].astype(int)
    results_df['x_coord_cd'] = results_df['x_coord_cd'].astype(float)
    results_df['y_coord_cd'] = results_df['y_coord_cd'].astype(float)
    results_df['latitude'] = results_df['latitude'].astype(float)
    results_df['longitude'] = results_df['longitude'].astype(float)
    results_df.to_sql('arrests', con=engine, index=False)
    results_df.to_csv(f"./raw_data/{i}.csv", index=False)

    