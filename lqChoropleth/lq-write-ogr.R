library(rgeos)
library(maptools)
library(gpclib)
library(rgdal)
library(foreign)

LQ <- read.table("~/Documents/r/output/LQ.csv", header = TRUE, sep = ",")
counties <- readOGR(dsn=path.expand("~/Documents/r/data/cb_2015_us_county_20m"), layer="cb_2015_us_county_20m")

merged <- merge(x=counties@data, y = LQ, by.x='FIPS',by.y='FIPS',all.x=TRUE)
ordering <- match(counties@data$FIPS , merged$FIPS)
counties@data <- merged[ordering,]

cbind(counties@data$FIPS,merged$FIPS[ordering])



writeOGR(counties, dsn=path.expand("~/Documents/r/data/counties"), 
         layer="counties", driver = "ESRI Shapefile" )
write.dbf(counties@data, file="~/Documents/r/data/counties/counties.dbf")
