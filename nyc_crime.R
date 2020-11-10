# Install packages
#install.packages("readr")
#install.packages("plyr")
#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("corrplot")

# Load packages
library(readr)
library(plyr)
library(dplyr)
library(ggplot2)
library(corrplot)

# --------------------------------------------------
# Data Processing 

# Import CSV and create dataframe using readr
df = read_csv("raw_data/NYPD_Arrests_Data__Historic_.csv")


# View first few rows of df
head(df)


# View df in new window
View(df)


# Number of rows
nrow(df)


# Count all rows
count(df)


# Show summary of data
summary(df)


# Remove all rows with NAs in any column
df = na.omit(df)


# Show object class
class(df)


# Change data types
df$ARREST_DATE = as.Date(df$ARREST_DATE, format = '%m/%d/%Y')


# Order df by ARREST_KEY ascending
df = df[order(df$ARREST_KEY),]


# Order df by ARREST_DATE descending
df = df[rev( order(df$ARREST_DATE) ),]


# Create new columns for Year, Month, Day
df$ARREST_YEAR = format(as.Date(df$ARREST_DATE, format = "%m/%d/%Y"), "%Y")
df$ARREST_MONTH = format(as.Date(df$ARREST_DATE, format = "%m/%d/%Y"), "%m")
df$ARREST_DAY = format(as.Date(df$ARREST_DATE, format = "%m/%d/%Y"), "%d")


# Change data types for Year, Month, Day
df$ARREST_YEAR = as.integer(df$ARREST_YEAR)
df$ARREST_MONTH = as.integer(df$ARREST_MONTH)
df$ARREST_DAY = as.integer(df$ARREST_DAY)

# Check if data type changed
class(df$ARREST_YEAR)
# "integer"


# Grab a particular value df[r,c]
df[1,1]


# Count rows by creating groups
count(df, ARREST_YEAR)


# Count rows based on condition
count(df, ARREST_YEAR == '2006')


# 



# --------------------------------------------------
# Visualization
