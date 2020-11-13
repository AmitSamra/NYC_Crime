![crime_big.png](img/crime_big.png)

[NYC OpenData](https://data.cityofnewyork.us/Public-Safety/NYPD-Arrests-Data-Historic-/8h9b-rp9u) offers data published by New York City agencies, including the New York City Police Department. This project performs exploratory analysis on NYPD historical valid arrests (those that were not voided due to lack of cause) spanning 14 years from 2006 to 2019, inclusive. I use R, ggplot2 and mongoDB to clean, analyze and persist data.  

![r_logo.png](img/r_logo.png)![ggplot2_logo.png](img/ggplot2_logo.png)![mongo_logo.png](img/mongo_logo.png)

# Table of Contents

1. Data Processing
2. Data Analysis & Visualization

# 1. Data Processing

After loading the CSV into a dataframe, we can observe that most of the data types are correct, except for dates. The dates must be properly formated in R. 

![load_data.png](img/load_data.png)

Viewing a subset of the dataframe shows us many columns like PD_CD, KY_CD, and OFNS_DESC provide no valuable information. 

![df_head](img/df_head.png)

In fact, there are 85 distinct values for OFNS_DESC. We can create a new column called CATEGORY to hold much simpler values to identify a category of crime.

![old_cat](img/old_cat.png)

With only 9 categories, it becomes easier to analyze the data for practical purposes.

![old_cat](img/old_cat.png)

[Home](https://github.com/AmitSamra/NYC_Crime#)

# 2. Data Analysis & Visualization



[Home](https://github.com/AmitSamra/NYC_Crime#)
