from sodapy import Socrata
import pandas as pd
from pymongo import MongoClient
from dotenv import load_dotenv
import os
import csv

dotenv_local_path = '.env'
load_dotenv(dotenv_path=dotenv_local_path, verbose=True)

client=Socrata(
"data.cityofnewyork.us",
os.environ.get("NYC_token"),
username=os.environ.get("NYC_username"),
password=os.environ.get("NYC_password")
)

