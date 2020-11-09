# Install packages
#install.packages("readr")
#install.packages("plyr")
#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("corrplot")
#install.packages("tidyverse")

# Load packages
library(readr)
library(plyr)
library(dplyr)
library(ggplot2)
library(corrplot)
#library(tidyverse)

# Import CSV and create dataframe using readr
df = read_csv("raw_data/NYPD_Arrests_Data__Historic_.csv")

# View first few rows of df
head(df)

# View df in new window
View(df)

# Number of rows
nrow(df)

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

