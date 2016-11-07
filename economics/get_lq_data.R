
library(plyr)
library(rgdal)
library(sp)
library(dplyr)
library(data.table)
counties <- readOGR("https://datahub.io/dataset/e82a4e76-ccf0-4d3a-b2c8-eda2b52ab32a/resource/f2693c94-fd69-4baf-887b-f302a5188ead/download/counties.geojson",
                    "OGRGeoJSON")

counties@data <- counties@data[,1:10]
counties@data <- merge(x = counties@data, y = lq, by = "FIPS")
str(counties@data)

### Create a data frame with the sectors and sector names 
sectors <- data.frame(cbind(
  c("101",	"1011",	"1012",	"1013",	"102",	"1021",	"1022",	
    "1023",	"1024",	"1025",	"1026",	"1027",	"1028",	"1029"),
  c("Producing",	"NatRes",	"Construction",	"Manufacturing",	
    "Services",	"Trade", "Information",	"Financial",	"Professional",	
    "EducationHealth",	"Hospitality",	"Other",	
    "Public",	"Unclassified")))
names(sectors) <- c("sector", "description")

### Use the BLS R function to access the industry-specific api - their notes below
# ******************************************************************************************
# qcewGetIndustryData : This function takes a year, quarter, and industry code
# and returns an array containing the associated industry data. Use 'a' for 
# annual averages. Some industry codes contain hyphens. The CSV files use
# underscores instead of hyphens. So 31-33 becomes 31_33. 
# For all industry codes and titles see:
# http://www.bls.gov/cew/doc/titles/industry/industry_titles.htm
qcewGetIndustryData <- function (year, qtr, industry) {
  url <- "http://www.bls.gov/cew/data/api/YEAR/QTR/industry/INDUSTRY.csv"
  url <- sub("YEAR", year, url, ignore.case=FALSE)
  url <- sub("QTR", qtr, url, ignore.case=FALSE)
  url <- sub("INDUSTRY", industry, url, ignore.case=FALSE)
  read.csv(url, header = TRUE, sep = ",", quote="\"", dec=".", na.strings=" ", skip=0)
}
### Use this loop to go through the sectors loaded in the data frame 
for (i in 1:length(sectors[,1])) {
  if (i == 1) {
    dt1 <- qcewGetIndustryData("2015", "3", sectors[1,1])
    dt1 <- aggregate(dt1$month2_emplvl, by=list(Category=dt1$area_fips), FUN=sum)
    names(dt1) <- c("area_fips", as.character(sectors[1,2]))
    
  } else if (i == 2) {
    print(paste("getting data for ", sectors[i,2]))
    
    dt2 <- qcewGetIndustryData("2015", "3", sectors[i,1])    
    dt2 <- aggregate(dt2$month2_emplvl, by=list(Category=dt2$area_fips), FUN=sum)
    names(dt2) <- c("area_fips", as.character(sectors[i,2]))
    data <- join(dt1, dt2, type = "inner")
    
  } else {
    print(paste("getting data for ", sectors[i,2]))
    
    dt3 <- qcewGetIndustryData("2015", "3", sectors[i,1])    
    dt3 <- aggregate(dt3$month2_emplvl, by=list(Category=dt3$area_fips), FUN=sum)
    names(dt3) <- c("area_fips", as.character(sectors[i,2]))
    data <- join(data, dt3, type = "inner")
  }
  
}

# Assign row names and column names for reference through the transformations
rownames(data) <- data$area_fips
colnames(data) <- c("Producing",	"NatRes",	"Construction",	"Manufacturing",	
                    "Services",	"Trade", "Information",	"Financial",	"Professional",	
                    "EducationHealth",	"Hospitality",	"Other",	
                    "Public",	"Unclassified")

str(data) # look at structure of the data

#####################################
# Now we go to the LQ functions ####
#####################################
# By Pierre-Alexandre Balland
# Department of Economic Geography, Utrecht University
# May 5, 2013

# This R script returns a location quotient (indicates the concentration of a particular technological classes, sectors, employment categories 
# in a given spatial unit. This is a ratio 
# As an input you just need a unit-by-region matrix in which the cells indicate the number of patents (or firms, or employees)
# a given spatial unit (a city, a country) has in a given economic unit.

### Convert the data frame to a matrix and take a look
data <- data.matrix( data[ ,2:length(data[1,]) ] )

# Calculate the share of each row made up by each instance
share_tech_city <- data / rowSums (data)
share_tech_total <- colSums (data) / sum (data)

# At the international level, agriculture accounts for 10 % of the economic activities (0.104)
head(share_tech_total)


LQ <- t(share_tech_city)/ share_tech_total

LQ[is.na(LQ)] <- 0 
LQ[which(LQ==Inf)] <- 0 

LQ <- t(LQ)

# here we go, this is the location quotient for each spatial unit - economic unit pair
# The LQ for London is 0.459 (0.048/0.104), which means that agriculture is less concentrated in London than worldwide (50% less)
head(LQ)


lqdf <- data.frame(LQ)

lqdf$COUNTYFP <- factor(substr(rownames(lqdf),3,5))

lqdf$STATEFP <- factor(substr(rownames(lqdf),0,2))
lqdf$FIPS <- factor(rownames(lqdf))

counties@data <- join(counties@data, lqdf, type = "inner")

