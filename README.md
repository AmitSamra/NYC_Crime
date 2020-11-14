![crime_big.png](img/crime_big.png)

[NYC OpenData](https://data.cityofnewyork.us/Public-Safety/NYPD-Arrests-Data-Historic-/8h9b-rp9u) offers data published by New York City agencies, including the New York City Police Department. This project performs exploratory analysis on NYPD historical valid arrests (those that were not voided due to lack of cause) spanning 14 years from 2006 to 2019, inclusive. I use R, ggplot2 and mongoDB to clean, analyze and persist data.  

![r_logo.png](img/r_logo.png)![ggplot2_logo.png](img/ggplot2_logo.png)![mongo_logo.png](img/mongo_logo.png)

# Table of Contents

1. [Data Processing](https://github.com/AmitSamra/NYC_Crime#1-data-processing)
2. [Data Analysis & Visualization](https://github.com/AmitSamra/NYC_Crime#2-data-analysis--visualization)
3. [Data Persistence into NoSQL Database](https://github.com/AmitSamra/NYC_Crime#3-data-persistence-into-nosql-database)

# 1. Data Processing

After loading the CSV into a dataframe, we can observe that most of the data types are correct, except for dates. The dates must be properly formated in R. 

![load_data.png](img/load_data.png)

Viewing a subset of the dataframe shows us many columns like PD_CD, KY_CD, and OFNS_DESC provide no valuable information. 

![df_head](img/df_head.png)

In fact, there are 85 distinct values for OFNS_DESC. We can create a new column called CATEGORY to hold much simpler values to identify a category of crime.

![old_cat](img/old_cat.png)

With only 9 categories, it becomes easier to analyze the data for practical purposes.

![old_cat](img/new_cat.png)

Similarly, we see that there exist numerous age cohorts due to data being entered erroneously. We must replace the incorrect values with "UNKNOWN".

![ages_wrong](img/ages_wrong.png)

[Home](https://github.com/AmitSamra/NYC_Crime#)

# 2. Data Analysis & Visualization

We begin our analysis of viewing a simple line plot of arrests over time. We can see a sharp increase in arrests starting in 2007, which ultimately peak in 2010, followed by gradual decline until 2014. After 2014, we notice noticeable drop in arrests.

![arrests_year.png](img/arrests_year.png)

By the end of 2014, arrests had fallen over 12.5%. One possible cause of the reduction in arrests may have been the inauguration of Bill De Blasio as mayor of NYC. According to Wikipedia, ["Exit polls showed that the issue that most aided de Blasio's primary victory was his unequivocal opposition to "stop and frisk"](https://en.wikipedia.org/wiki/Bill_de_Blasio#2013_election). It is important to note that the reduction in arrests does not imply a reduction in crime. 

![arrests_year_pc.png](img/arrests_year_pc.png)

Another way of analyzing the trends in arrests over time is viewing a trend line for each year. From this chart we can see a reduction in arrests over time, with 2019 having the lowest number of arrests since 2006. We can also see some seasonality in arrests, which tend to peak in March and October of every year. 

![arrests_month_year.png](img/arrests_month_year.png)

A bar graph of arrests by month shows that arrests occur more in spring and autumn. 

![arrests_month.png](img/arrests_month.png)

The overwhelming majority of arrests were related misdemeanors followed by felonies. Arrests for lesser crimes like violations and infractions were rare in comparison. 

![arrests_type.png](img/arrests_type.png)

Using the 9 categories we created, we see that THEFT & FRAUD and DRUGS were the two single largest categories of arrests. 

![top_10_cat.png](img/top_10_cat.png)

An even more granular view using OFNS_DESC shows that DRUGS were the single largest reason for arrests. 

![top_10_ofns.png](img/top_10_ofns.png)

Filtering the data for only drug arrests, we see that arrests for drugs have fallen each since 2011. 

![arrests_drugs.png](img/arrests_drugs.png)

Again, we see a precipitous drop in both 2011 and 2014. 

![arrests_drugs_pc.png](img/arrests_drugs_pc.png)

Brooklyn and Manhattan are the leading boroughs for arrests. 

![arrests_boro.png](img/arrests_boro.png)

Most arrests occur for the 25-44 age cohort followed by the 18-24 cohort. 

![arrests_age.png](img/arrests_age.png)

The same trends are true for felony arrests alone. 

![arrests_age_fel.png](img/arrests_age_fel.png)

To see the trend more clearly, we can plot the arrests by cohort for all crimes vs. only felonies on the same chart. 

![arrests_age_all_fel.png](img/arrests_age_all_fel.png)

Over 83% of those arrested were men. 

![arrests_sex.png](img/arrests_sex.png)

The same trend hold for felony arrests. 

![arrests_sex_fel.png](img/arrests_sex_fel.png)

# 3. Data Persistence into NoSQL Database

And finally, we can store the clean dataframe into a NoSQL Database. 

![nosql_data.png](img/nosql_data.png)

This concludes my presentation. Thank you! 

[Home](https://github.com/AmitSamra/NYC_Crime#)
