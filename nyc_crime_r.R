# Install packages
#install.packages("readr")
#install.packages("plyr")
#install.packages("dplyr")
#install.packages("ggplot2")
#install.packages("corrplot")
#install.packages("ggrepel")
#install.packages("usethis")
#install.packages("RSocrata")
#install.packages("mongolite")

# Load packages
library(readr)
library(plyr)
library(dplyr)
library(ggplot2)
library(corrplot)
library(scales)
library(ggrepel)
library(usethis)
library(RSocrata)
library(mongolite)

options(scipen=999)

usethis::edit_r_environ("project")
readRenviron(".Renviron")

# --------------------------------------------------
# Data Processing
# --------------------------------------------------

# Import CSV and create dataframe using readr
df2 = read_csv("raw_data/NYPD_Arrests_Data__Historic_.csv")

# Make connection to mongoDB
c=mongo(db='nyc_crime', collection='arrests')

# Import data from mongoDB using 
df = c$find('{}')

View(df)

df$arrest_date = substr(df$arrest_date, 1, 10)

# View first few rows of df
head(df)

# View df in new window
View(df)
class(df$arrest_date)
# Count all rows
count(df)

# Show summary of data
summary(df)

# Remove all rows with NAs in any column
df = na.omit(df)

# Change data types
df$arrest_date = as.Date(df$arrest_date, format = '%Y-%m-%d')

# Order df by ARREST_KEY descending
df = df[rev( order(df$arrest_key) ),]

# Create new columns for Year, Month, Day
#df$ARREST_YEAR = format(as.Date(df$ARREST_DATE, format = "%m/%d/%Y"), "%Y")
#df$ARREST_MONTH = format(as.Date(df$ARREST_DATE, format = "%m/%d/%Y"), "%m")
#df$ARREST_DAY = format(as.Date(df$ARREST_DATE, format = "%m/%d/%Y"), "%d")

df$arrest_year = format(as.Date(df$arrest_date, format = "%Y-%m-%d"), "%Y")
df$arrest_month = format(as.Date(df$arrest_date, format = "%Y-%m-%d"), "%m")
df$arrest_day = format(as.Date(df$arrest_date, format = "%Y-%m-%d"), "%d")

# Change data types for Year, Month, Day
df$ARREST_YEAR = as.integer(df$ARREST_YEAR)
df$ARREST_MONTH = as.integer(df$ARREST_MONTH)
df$ARREST_DAY = as.integer(df$ARREST_DAY)
# --------------------------------------------------
# Reducing crime categories for simpler reporting

# Count all OFNS_DESC
length(unique(df$OFNS_DESC))
# There are 85 different values for OFNS_DESC

# Show call OFNS_DESC
unique(df$OFNS_DESC)

# THEFT_FRAUD
THEFT = c("BURGLARY","PETIT LARCENY","OFFENSES INVOLVING FRAUD","THEFT OF SERVICES","POSSESSION OF STOLEN PROPERTY 5","THEFT-FRAUD",
          "OTHER OFFENSES RELATED TO THEF","FRAUDULENT ACCOSTING","ROBBERY","GRAND LARCENY OF MOTOR VEHICLE",
          "POSSESSION OF STOLEN PROPERTY","GRAND LARCENY","FORGERY","BURGLAR'S TOOLS","FRAUDS","OTHER OFFENSES RELATED TO THEFT",
          "JOSTLING","CRIMINAL TRESPASS")
df$CATEGORY[df$OFNS_DESC %in% THEFT] = "THEFT & FRAUD"

# DRUGS
DRUGS = c("DANGEROUS DRUGS","LOITERING FOR DRUG PURPOSES","UNDER THE INFLUENCE, DRUGS")
df$CATEGORY[df$OFNS_DESC %in% DRUGS] = "DRUGS"

# WEAPONS
WEAPONS = c("DANGEROUS WEAPONS","UNLAWFUL POSS. WEAP. ON SCHOOL","UNLAWFUL POSS. WEAP. ON SCHOOL GROUNDS")
df$CATEGORY[df$OFNS_DESC %in% WEAPONS] = "WEAPONS"

# ASSAULT
ASSAULT = c("FELONY ASSAULT","ASSAULT 3 & RELATED OFFENSES")
df$CATEGORY[df$OFNS_DESC %in% ASSAULT] = "ASSAULT"

# SEXUAL_ASSAULT
SEXUAL_ASSAULT = c("RAPE","SEX CRIMES","FORCIBLE TOUCHING")
df$CATEGORY[df$OFNS_DESC %in% SEXUAL_ASSAULT] = "SEXUAL ASSAULT"

# TRAFFIC
TRAFFIC = c("INTOXICATED & IMPAIRED DRIVING","VEHICLE AND TRAFFIC LAWS","MOVING INFRACTIONS","PARKING OFFENSES",
            "INTOXICATED/IMPAIRED DRIVING","OTHER TRAFFIC INFRACTION", "UNAUTHORIZED USE OF A VEHICLE 3 (UUV)",
            "UNAUTHORIZED USE OF A VEHICLE")
df$CATEGORY[df$OFNS_DESC %in% TRAFFIC] = "TRAFFIC"

# MURDER
MURDER = c("MURDER & NON-NEGL. MANSLAUGHTE", "MURDER & NON-NEGL. MANSLAUGHTER", "HOMICIDE-NEGLIGENT,UNCLASSIFIED", 
           "HOMICIDE-NEGLIGENT-VEHICLE","HOMICIDE-NEGLIGENT,UNCLASSIFIE")
df$CATEGORY[df$OFNS_DESC %in% MURDER] = "MURDER"

# CHILDREN
CHILDREN = c("KIDNAPPING", "CHILD ABANDONMENT/NON SUPPORT 1", "KIDNAPPING & RELATED OFFENSES", "OFFENSES RELATED TO CHILDREN",
             "CHILD ABANDONMENT/NON SUPPORT")
df$CATEGORY[df$OFNS_DESC %in% CHILDREN] = "CHILDREN"

# OTHER
ALL_CAT = c(THEFT, DRUGS, WEAPONS, ASSAULT, SEXUAL_ASSAULT, MURDER, CHILDREN, TRAFFIC)
df$CATEGORY[!df$OFNS_DESC %in% ALL_CAT] = "OTHER"

unique(df$CATEGORY)
# "OTHER" "ASSAULT" "THEFT & FRAUD" "TRAFFIC" "WEAPONS" "DRUGS" "SEXUAL ASSAULT" "MURDER" "CHILDREN"      

# --------------------------------------------------
# Drop unnecessary columns
df = within(df, rm(PD_CD, KY_CD, LAW_CODE, JURISDICTION_CODE))

# --------------------------------------------------
# Fix age cohorts

# Note the strange result by creating this dataframe
df_arrests_age = df %>%
  group_by(AGE_GROUP) %>%
  summarize(total_arrests=n())
df_arrests_age
# This yields in a weird result because the age groups are incorrect

# There are 91 distinct values in the AGE_GROUP column
unique(df$AGE_GROUP)

# Let's replace the values don't make sense with "UNKNOWN"

good_ages = c('<18', '18-24', '25-44', '45-64', '65+')
df$AGE_GROUP[!df$AGE_GROUP %in% good_ages] = 'UNKNOWN'

# Now there are only 6 distinct values in AGE_GROUP
unique(df$AGE_GROUP)

# --------------------------------------------------
# Data Analysis and Visualization
# --------------------------------------------------

# Plot arrests by year
# Let's build the plot syntax for the dplyr method in pieces
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
  ggplot( aes ( x = ARREST_YEAR, y = total_arrests, group = 1) ) + 
  geom_line()

# Save plot
ggsave("arrests_year.png", device = "png", path = "img")

# Let's format the graph
# First we create a separate dataframe that we wish to plot

df_arrests_year = df %>%
  group_by(ARREST_YEAR) %>%
  summarize(total_arrests = n())

# Next we plot as we did above
df_arrests_year %>% 
  ggplot( aes(x = ARREST_YEAR, y = total_arrests) ) + 
    geom_line(color = "steel blue") +
    ggtitle("Total Arrests by Year") +
    xlab("Year") +
    ylab("Number of Arrests") +
    scale_y_continuous(breaks = seq(0,max(df_arrests_year$total_arrests),5000), labels=comma) +
    scale_x_continuous(breaks = seq(min(df_arrests_year$ARREST_YEAR),max(df_arrests_year$ARREST_YEAR),1))

# This is an alternative way of setting the y-axis labels:
df_arrests_year %>% 
  ggplot( aes(x = ARREST_YEAR, y = total_arrests) ) + 
  geom_line(color = "steel blue") +
  ggtitle("Total Arrests by Year") +
  xlab("Year") +
  ylab("Number of Arrests") +
  scale_y_continuous(breaks = scales::breaks_extended(n=10), labels=comma) +
  scale_x_continuous(breaks = seq(min(df_arrests_year$ARREST_YEAR),max(df_arrests_year$ARREST_YEAR),1))

# We can also add labels to the graph
df_arrests_year %>% 
  ggplot( aes(x = ARREST_YEAR, y = total_arrests, label=total_arrests) ) + 
  geom_line(color = "steel blue") +
  ggtitle("Total Arrests by Year") +
  xlab("Year") +
  ylab("Number of Arrests") +
  scale_y_continuous(breaks = scales::breaks_extended(n=10), labels=comma) +
  #scale_y_continuous(breaks = df_arrests_year$total_arrests) +
  scale_x_continuous(breaks = seq(min(df_arrests_year$ARREST_YEAR),max(df_arrests_year$ARREST_YEAR),1)) +
  geom_text(hjust=0, vjust=-1, size=3) +
  geom_point(color='steel blue')

ggsave("arrests_year.png", device="png", path="img")


# Add percentage change
df_arrests_year_pc = mutate(df_arrests_year, change=(total_arrests/lag(total_arrests))-1)

df_arrests_year_pc %>% 
  ggplot( aes(x = ARREST_YEAR, y = total_arrests, label=scales::percent(change)) ) + 
  geom_line(color = "red") +
  ggtitle("Change in Arrests") +
  xlab("Year") +
  ylab("Number of Arrests") +
  scale_y_continuous(breaks = scales::breaks_extended(n=10), labels=comma) +
  scale_x_continuous(breaks = seq( min(df_arrests_year_pc$ARREST_YEAR), max(df_arrests_year_pc$ARREST_YEAR),1)) +
  geom_text(hjust=0, vjust=-1, size=3) +
  geom_point(color = 'red')

ggsave("arrests_year_pc.png", device="png", path="img")


# --------------------------------------------------

# Plot drug arrests for all years
df_arrests_drugs = df %>%
  filter(CATEGORY == 'DRUGS') %>%
  group_by(ARREST_YEAR) %>%
  summarize(total_arrests = n())
  
df_arrests_drugs %>%
  ggplot( aes(x=ARREST_YEAR, y=total_arrests, label=total_arrests) ) +
  geom_line(color = 'steel blue') +
  ggtitle("Drug Arrests by Year") +
  xlab("Year") +
  ylab("Number of Arrests") +
  scale_y_continuous(breaks = scales::breaks_extended(n=10), labels=comma) +
  scale_x_continuous(breaks = seq( min(df_arrests_drugs$ARREST_YEAR), max(df_arrests_drugs$ARREST_YEAR), 1)) +
  geom_text(hjust=0, vjust=-1, size=3) +
  geom_point(color='steel blue')

ggsave("arrests_drugs.png", device="png", path="img")


# Plot drug arrests percent change
df_arrests_drugs_pc = mutate(df_arrests_drugs, change=(total_arrests/lag(total_arrests))-1)

df_arrests_drugs_pc %>% 
  ggplot( aes(x=ARREST_YEAR, y=total_arrests, label=scales::percent(change))) +
  geom_line(color = 'red') +
  ggtitle("Change in Drug Arrests") +
  xlab("Year") +
  ylab("Number of Arrests") +
  scale_y_continuous(breaks = scales::breaks_extended(n=10), labels = comma) +
  scale_x_continuous(breaks = seq( min(df_arrests_drugs_pc$ARREST_YEAR), max(df_arrests_drugs_pc$total_arrests), 1)) +
  geom_text(hjust=0, vjust=-1, size=3) +
  geom_point(color='red')

ggsave("arrests_drugs_pc.png", device="png", path="img")


# --------------------------------------------------
# ????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
# Plot total arrests with line for each year
df_arrests_month_year = df %>%
  group_by(ARREST_YEAR, ARREST_MONTH) %>%
  summarize(total_arrests = n())

df_arrests_month_year = df_arrests_month_year %>%
  mutate(ARREST_MONTH = factor(month.abb[months], levels = month.abb))

df_arrests_month_year

df_arrests_month_year %>%
  ggplot(aes(x=ARREST_MONTH, y=total_arrests, group=ARREST_YEAR, color=as.factor(ARREST_YEAR))) +
  geom_line() +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  #geom_text() +
  ggtitle('Arrests by Month per Year') +
  xlab('Month') +
  ylab('Number of Arrests') +
  scale_color_manual(values=c('blue','red','black','yellow','green','purple','orange','dark green','gray48','steel blue',
                              'mediumvioletred','saddlebrown','powderblue','navy'))
# as.factor(ARREST_YEAR) is needed because an error arises

ggsave('arrests_month_year.png', device='png', path='img')


# --------------------------------------------------

# Arrests by Month
df_arrests_month_name = df %>%
  group_by(ARREST_MONTH) %>%
  summarize(total_arrests = n())

df_arrests_month_name

df_arrests_month_name= df_arrests_month %>% 
  mutate(ARREST_MONTH = factor(month.abb[months], levels = month.abb))

df_arrests_month_name

df_arrests_month_name %>%
  ggplot(aes(x=ARREST_MONTH, y=total_arrests), label=total_arrests) +
  geom_bar(stat='identity', fill='red3') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  ggtitle('Arrests by Month') +
  ylab('Numer of Arrests') +
  xlab('Month')

ggsave('arrests_month_name.png', device='png', path='img')

# or we can use the number of the month

df_arrests_month = df %>%
  group_by(ARREST_MONTH) %>%
  summarize(total_arrests = n())

df_arrests_month = df_arrests_month %>%
  mutate(ARREST_MONTH = factor(ARREST_MONTH))

df_arrests_month %>%
  ggplot(aes(x=ARREST_MONTH, y=total_arrests), label=total_arrests) +
  geom_bar(stat='identity', fill='red3') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  ggtitle('Arrests by Month') +
  ylab('Numer of Arrests') +
  xlab('Month') 

ggsave('arrests_month.png', device='png', path='img')


# --------------------------------------------------

# Top 10 crimes by OFNS_DESC
df_top_10 = df %>%
  group_by(OFNS_DESC) %>%
  summarize(total_arrests = n())
# sort desc
df_top_10 = top_n(df_top_10, 10, total_arrests) %>%
  arrange(desc(total_arrests))
df_top_10 %>%
  ggplot(aes(x=OFNS_DESC, y=total_arrests, label=total_arrests)) +
  geom_bar(stat='identity', fill='steel blue') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  theme(axis.text.x=element_text(angle=90,hjust=1)) +
  aes(x = reorder(OFNS_DESC, -total_arrests)) +
  ggtitle('Arrests by Offense Description') +
  xlab('Offense Description') +
  ylab('Number of Arrests')

ggsave('top_10_ofns.png', device='png', path='img')
  

# Top crimes by CATEGORY
df_top_cat = df %>%
  group_by(CATEGORY) %>%
  summarize(total_arrests = n())
df_top_cat = top_n(df_top_cat,length(unique(df$CATEGORY)),total_arrests) %>%
  arrange(desc(total_arrests))

df_top_cat %>%
  ggplot(aes(x=CATEGORY, y=total_arrests, label=total_arrests)) +
  geom_bar(stat='identity', fill='steel blue') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  theme(axis.text.x=element_text(angle=90,hjust=1)) +
  aes(x=reorder(CATEGORY, -total_arrests)) +
  ggtitle('Arrests by Category') +
  xlab('Category') +
  ylab('Number of Arrests')

ggsave('top_10_cat.png', device='png', path='img')


# --------------------------------------------------

# Crimes by Misdemeanors, Felonies, Violations, Infractions

df_crime_type = df %>%
  group_by(LAW_CAT_CD) %>%
  summarize(total_arrests = n())

df_crime_type %>%
  ggplot(aes(x=LAW_CAT_CD, y=total_arrests), label=total_arrests) +
  geom_bar(stat='identity', fill='red3') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  aes(x=reorder(LAW_CAT_CD, -total_arrests)) +
  ggtitle('Arrests by Crime Type') +
  xlab('Crime Type') +
  ylab('Number of Arrests')

ggsave('arrests_type.png', device='png', path='img')


# --------------------------------------------------

# Arrests by Borough

df_arrests_boro = df %>%
  group_by(ARREST_BORO) %>%
  summarize(total_arrests = n())

df_arrests_boro %>% 
  ggplot(aes(x=ARREST_BORO, y=total_arrests), label=total_arrests) +
  geom_bar(stat='identity', fill='steel blue') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  aes(x=reorder(ARREST_BORO, -total_arrests), label= 'Total') +
  ggtitle('Arrests by Borough') +
  ylab('Numer of Arrests') +
  xlab('Borough')

ggsave('arrests_boro.png', device='png', path='img')


# --------------------------------------------------

# Create subsets to merge & compute correlation matrix

df_2019 = df %>%
  filter(ARREST_YEAR == 2019) %>%
  group_by(ARREST_MONTH) %>%
  summarize('2019' = n())

df_2015 = df %>%
  filter(ARREST_YEAR == 2015) %>%
  group_by(ARREST_MONTH) %>%
  summarize('2015' = n())

df_2011 = df %>%
  filter(ARREST_YEAR == 2011) %>%
  group_by(ARREST_MONTH) %>%
  summarize('2011' = n())

df_11_15 = merge(df_2011,df_2015)
df_11_15_19 = merge(df_11_15,df_2019)
df_11_15_19

# Drop month column
df_11_15_19 = select(df_11_15_19, -1)
df_11_15_19

# Compute correlation matrix
cor(df_11_15_19)

# Plot correlations
corrplot(cor(df_11_15_19), method='circle')

# Compute correlation for only subset of columns
cor(df_11_15_19[1],df_11_15_19[2])


# --------------------------------------------------

# Plot total arrests by age



# We must filter only the results that make sense

df_arrests_age = df %>%
  group_by(AGE_GROUP) %>%
  summarize(total_arrests=n())

df_arrests_age %>%
  ggplot(aes(x=AGE_GROUP, y=total_arrests), label=total_arrets) +
  geom_bar(stat='identity', fill='aquamarine4') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  ggtitle('Arrests by Age') +
  xlab('Age Group') +
  ylab('Number of Arrests')

ggsave('arrests_age.png', device='png', path='img')


# --------------------------------------------------

# Plot arrests by age for felonies

df_arrests_age_fel = df %>%
  filter(LAW_CAT_CD == 'F') %>%
  group_by(AGE_GROUP) %>%
  summarize(total_arrests=n())

df_arrests_age_fel %>%
  ggplot(aes(x=AGE_GROUP, y=total_arrests), label=total_arrets) +
  geom_bar(stat='identity', fill='aquamarine3') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  ggtitle('Felony Arrests by Age') +
  xlab('Age Group') +
  ylab('Number of Arrests')

ggsave('arrests_age_fel.png', device='png', path='img')


# --------------------------------------------------

# Plot all arrests by age & arrests for felonies by age on same chart

df_arrests_age_comb = dplyr::bind_rows(df_arrests_age, df_arrests_age_fel, .id='id')
df_arrests_age_comb

df_arrests_age_comb %>%
  ggplot(aes(x=AGE_GROUP, y=total_arrests, fill=id), label=total_arrets) +
  geom_bar(stat='identity') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  ggtitle('All Arrests vs. Felony Arrests by Age') +
  scale_fill_manual(labels=c('All Arrests','Felonies'), values=c('aquamarine4','aquamarine3')) +
  labs(title='All Arrests vs. Felony Arrests by Age', x='Age Group', y='Number of Arrests', fill='Arrest Severity')

# if the labels overlapping are troublesome, use ggrepel

df_arrests_age_comb %>%
  ggplot(aes(x=AGE_GROUP, y=total_arrests, fill=id, label=total_arrests)) +
  geom_bar(stat='identity') +
  scale_y_continuous(breaks=scales::breaks_extended(n=10), labels=comma) +
  #geom_text(hjust=.5, vjust=-1, size=3, aes(label=comma(total_arrests))) +
  ggtitle('All Arrests vs. Felony Arrests by Age') +
  scale_fill_manual(labels=c('All Arrests','Felonies'), values=c('aquamarine4','aquamarine3')) +
  labs(title='All Arrests vs. Felony Arrests by Age', x='Age Group', y='Number of Arrests', fill='Arrest Severity') +
  geom_text_repel(vjust=2, direction='y', segment.color='transparent', aes(label=comma(total_arrests)), size=3)

ggsave('arrests_age_all_fel.png', device='png', path='img')


# --------------------------------------------------

# Pie chart by sex

df_sex = df %>%
  group_by(PERP_SEX) %>%
  summarize(total_arrests = n()) %>%
  arrange(desc(total_arrests))

df_sex = df_sex %>%
  mutate(prop=total_arrests/sum(total_arrests), prop=scales::percent(prop,.10))

df_sex %>%
  ggplot(aes(x='', y=total_arrests, label=prop, fill=PERP_SEX)) +
  geom_bar(stat='identity') +
  coord_polar('y', start=1) +
  theme_void() +
  scale_fill_manual(labels=c('Female','Male'), values=c('lightpink2','steel blue')) +
  geom_text(hjust=0, vjust=0, size=3, aes(label=prop), color="black", position=position_stack(vjust=.5)) +
  labs(title='Arrest Share by Sex', fill='Sex')

ggsave('arrests_sex.png', device='png', path='img')


# --------------------------------------------------

# Doughnut chart for felony arrests by sex

df_sex_fel = df %>%
  filter(LAW_CAT_CD=='F') %>%
  group_by(PERP_SEX) %>%
  summarize(total_arrests = n()) %>%
  arrange(desc(total_arrests))

df_sex_fel = df_sex_fel %>%
  mutate(prop=total_arrests/sum(total_arrests), prop=scales::percent(prop,.10))

df_sex_fel %>%
  ggplot(aes(x=2, y=total_arrests, label=prop, fill=PERP_SEX)) +
  geom_bar(stat='identity') +
  coord_polar(theta='y', start=1) +
  #theme_void() +
  scale_fill_manual(labels=c('Female','Male'), values=c('lightpink2','steel blue')) +
  geom_text(hjust=0, vjust=0, size=3, aes(label=prop), color="black", position=position_stack(vjust=.5)) +
  labs(title='Felony Arrest Share by Sex', fill='Sex') +
  xlim(0.5,2.5) +
  theme(panel.background=element_blank(),
        axis.line=element_blank(),
        axis.text=element_blank(),
        axis.ticks=element_blank(),
        axis.title=element_blank(), 
        plot.title=element_text(hjust=0.5, size=20))

ggsave('arrests_sex_fel.png', device='png', path='img')

# --------------------------------------------------
# Data Persistence in NoSQL Database
# --------------------------------------------------

# Make connection to mongoDB
c=mongo(db='nyc_crime', collection='arrests')

# Insert all documents into arrests collection
c$insert(df)

# Count shows number of documents in mongoDB
c$count()

# We can also create a dataframe R by quering data from mongoDB

#df_from_mongo = c$find('{}')
