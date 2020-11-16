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

# Create table arrests

#engine.execute("DROP TABLE IF EXISTS arrests;")
engine.execute(
"""
CREATE TABLE IF NOT EXISTS arrests (
arrest_key int not null primary key,
arrest_date date,
pd_cd int,
pd_desc varchar(50),
ky_cd int,
ofns_desc varchar(50),
law_code varchar(50),
law_cat_cd varchar(50),
arrest_boro varchar(50),
arrest_precinct int,
jurisdiction_code int,
age_group varchar(50),
perp_sex varchar(50),
perp_race varchar(50),
x_coord_cd bigint(15),
y_coord_cd bigint(15),
latitude numeric(15,10),
longitude numeric(15,10)
);
"""
)

# Retrieve data from API, tranform and ingest into MySQL

start_year=2006
end_year=2019

for i in range(start_year, end_year+1, 1):
    
    results = client.get("8h9b-rp9u", where="arrest_date between "+"'"+str(i)+"-01-01'"+" and "+"'"+str(i)+"-01-31'", limit=10000000)
    results_df = pd.DataFrame.from_records(results)
    
    results_df = results_df.drop('lon_lat',1)
    
    results_df['arrest_key'] = results_df['arrest_key'].str.strip()
    results_df['arrest_key'] = results_df['arrest_key'].astype(int)
    
    results_df['arrest_date'] = results_df['arrest_date'].str.strip()
    results_df['arrest_date'] = results_df['arrest_date'].astype(str)
    results_df['arrest_date'] = results_df['arrest_date'].str.slice(0,10)
    
    results_df['pd_cd'] = results_df['pd_cd'].str.strip()
    results_df['pd_cd'] = results_df['pd_cd'].str.replace('NULL', '0')
    results_df['pd_cd'] = results_df['pd_cd'].fillna('0')
    results_df['pd_cd'] = results_df['pd_cd'].astype(float)
    results_df['pd_cd'] = results_df['pd_cd'].astype(int)
    
    results_df['pd_desc'] = results_df['pd_desc'].str.strip()
    results_df['pd_desc'] = results_df['pd_desc'].str.replace('NULL', 'UNKNOWN')
    results_df['pd_desc'] = results_df['pd_desc'].fillna('UNKNOWN')
    
    results_df['ky_cd'] = results_df['ky_cd'].str.strip()
    results_df['ky_cd'] = results_df['ky_cd'].str.replace('NULL', '0')
    results_df['ky_cd'] = results_df['ky_cd'].fillna('0')
    results_df['ky_cd'] = results_df['ky_cd'].astype(float)
    results_df['ky_cd'] = results_df['ky_cd'].astype(int)  
    
    results_df['ofns_desc'] = results_df['ofns_desc'].str.strip()
    results_df['ofns_desc'] = results_df['ofns_desc'].str.replace('NULL', 'UNKNOWN')
    results_df['ofns_desc'] = results_df['ofns_desc'].fillna('UNKNOWN')
    
    results_df['law_code'] = results_df['law_code'].str.strip()
    results_df['law_code'] = results_df['law_code'].str.replace('NULL', 'UNKNOWN')
    results_df['law_code'] = results_df['law_code'].fillna('UNKNOWN')
    
    results_df['law_cat_cd'] = results_df['law_cat_cd'].str.strip()
    results_df['law_cat_cd'] = results_df['law_cat_cd'].str.replace('NULL', 'UNKNOWN')
    results_df['law_cat_cd'] = results_df['law_cat_cd'].fillna('UNKNOWN')
    
    results_df['arrest_boro'] = results_df['arrest_boro'].str.strip()
    results_df['arrest_precinct'] = results_df['arrest_precinct'].str.strip()
    results_df['arrest_precinct'] = results_df['arrest_precinct'].astype(int)
    
    results_df['jurisdiction_code'] = results_df['jurisdiction_code'].str.strip()
    results_df['jurisdiction_code'] = results_df['jurisdiction_code'].str.replace('NULL', '0')
    results_df['jurisdiction_code'] = results_df['jurisdiction_code'].fillna('0')
    results_df['jurisdiction_code'] = results_df['jurisdiction_code'].astype(float)
    results_df['jurisdiction_code'] = results_df['jurisdiction_code'].astype(int)
    
    results_df['age_group'] = results_df['age_group'].str.strip()
    results_df['perp_sex'] = results_df['perp_sex'].str.strip()
    results_df['perp_race'] = results_df['perp_race'].str.strip()
    
    results_df['x_coord_cd'] = results_df['x_coord_cd'].str.strip()
    results_df['x_coord_cd'] = results_df['x_coord_cd'].astype(float)
    
    results_df['y_coord_cd'] = results_df['y_coord_cd'].str.strip()
    results_df['y_coord_cd'] = results_df['y_coord_cd'].astype(float)
    
    results_df['latitude'] = results_df['latitude'].str.strip()
    results_df['latitude'] = results_df['latitude'].astype(float)
    
    results_df['longitude'] = results_df['longitude'].str.strip()
    results_df['longitude'] = results_df['longitude'].astype(float)
    
    results_df.to_sql('arrests', con=engine, index=False, if_exists='replace')
    results_df.to_csv(f"./raw_data/{i}.csv", index=False)

