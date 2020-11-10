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
library(scales)

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
# count() is a dplyr function
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
# count() is a dplyr function
count(df, ARREST_YEAR)


# Count rows based on condition
length( which(df$ARREST_YEAR == 2006) )


# Filter using base R command to create a subset
df_2006_base = df[df$ARREST_YEAR == 2006, ]


# Using dplyr, we can simplify the syntax to create a subset
df_2006_dplyr = filter(df, (ARREST_YEAR == 2006))


# Filter all rows using multiple conditions using base
df_2006_drugs_base = df[df$ARREST_YEAR == 2006 & df$KY_CD == 235,]
View(df_2006_drugs_base)


# Filter all rows using multiple conditions using dplyr
df_2006_drugs_dplyr = filter(df, (ARREST_YEAR == 2006 & KY_CD == 235))
View(df_2006_drugs_dplyr)


# --------------------------------------------------
# Visualization

# Plot total arrests by year using base R
table(df$ARREST_YEAR) %>% plot(type='l')


# Let's build the plot syntax for dplyr in pieces
# group_by() groups each record by year
df %>%
  group_by(ARREST_YEAR)

# Adding summarize() sums all of the records for each year
df %>%
  group_by(ARREST_YEAR) %>%
  summarize(total_arrests = n())
  
# Lastly ggplot() is used to plot
df %>%
  group_by(ARREST_YEAR) %>%
  summarize(total_arrests = n()) %>%
  ggplot( aes ( x = ARREST_YEAR, y = total_arrests, group = 1) ) + geom_line()

# Save plot
ggsave("arrests_year.png", device = "png", path = "img")

# Let's format the graph
# First we create a separate dataframe that we wish to plot

df_year_arrests = df %>%
  group_by(ARREST_YEAR) %>%
  summarize(total_arrests = n())

# Next we plot as we did above
df_year_arrests %>% 
  ggplot( aes(x = ARREST_YEAR, y = total_arrests) ) + 
    geom_line(color = "steel blue") +
    ggtitle("Total Arrests by Year") +
    xlab("Year") +
    ylab("Number of Arrests") +
    scale_y_continuous(breaks = seq(0,max(df_year_arrests$total_arrests),5000), labels=comma) +
    scale_x_continuous(breaks = seq(min(df$ARREST_YEAR),max(df$ARREST_YEAR),1))

# This is an alternative way of setting the y-axis labels:
df_year_arrests %>% 
  ggplot( aes(x = ARREST_YEAR, y = total_arrests) ) + 
  geom_line(color = "steel blue") +
  ggtitle("Total Arrests by Year") +
  xlab("Year") +
  ylab("Number of Arrests") +
  scale_y_continuous(breaks = scales::breaks_extended(n=10), labels=comma) +
  scale_x_continuous(breaks = seq(min(df$ARREST_YEAR),max(df$ARREST_YEAR),1))

# We can also add labels to the graph
df_year_arrests %>% 
  ggplot( aes(x = ARREST_YEAR, y = total_arrests, label=total_arrests) ) + 
  geom_line(color = "steel blue") +
  ggtitle("Total Arrests by Year") +
  xlab("Year") +
  ylab("Number of Arrests") +
  scale_y_continuous(breaks = scales::breaks_extended(n=10), labels=comma) +
  #scale_y_continuous(breaks = df_year_arrests$total_arrests) +
  scale_x_continuous(breaks = seq(min(df$ARREST_YEAR),max(df$ARREST_YEAR),1)) +
  geom_text(hjust=0, vjust=-1, size=3)

ggsave("arrests_year.png", device = "png", path = "img")


# Add percentage change
df_year_arrests_pc = mutate(df_year_arrests, change=(total_arrests-lag(total_arrests))/lag(total_arrests))

df_year_arrests_pc %>% 
  ggplot( aes(x = ARREST_YEAR, y = total_arrests, label=scales::percent(change)) ) + 
  geom_line(color = "steel blue") +
  ggtitle("Change in Arrests") +
  xlab("Year") +
  ylab("Number of Arrests") +
  scale_y_continuous(breaks = scales::breaks_extended(n=10), labels=comma) +
  scale_x_continuous(breaks = seq(min(df$ARREST_YEAR),max(df$ARREST_YEAR),1)) +
  geom_text(hjust=0, vjust=-1, size=3)

ggsave("arrests_year_percent.png", device = "png", path = "img")
