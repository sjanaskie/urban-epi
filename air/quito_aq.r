---
title: "Quito air quality - modeled on Beijing Air Quality"
author: "Moroney & Thomas"
date: "Sep 21, 2016"
output: html_document
---

``````{r global_options, include=FALSE}
knitr::opts_chunk$set(fig.width=12, fig.height=8,
                      warning=FALSE, message=FALSE)
```

```{r}
library(zoo)
library(lubridate)
library(plotrix)
library(dplyr)
library(animation)
library(tidyr)
library(ggplot2)

## READ IN DATA from DataHub

aq <- read.table(paste0("https://datahub.io/dataset/c83708cc-0737-4f85-9bbd-04b254c60924",
"/resource/5ce33a23-188f-4326-abe1-047a787f9df5/download/airquality.tsv"), 
header=TRUE, sep="\t", as.is=T, na.strings = "NA")

## COLUMN VARIABLES TO CORRECT CLASS
# date to posix
# abbreviated month name in spanish? need to set sys locale to understand
Sys.setlocale(locale="es_ES.utf8")
aq$date <- as.POSIXct(parse_date_time(aq$yyyy.mm.dd.hh,"%Y-%b-%d-%H")) #432 failed to parse
# chemical type to factor
aq$Type <- as.factor(aq$Type)
# make conc values numeric from character. 
aq[, 3:14] <- sapply(aq[, 3:14], as.numeric) #creates some NAs from the NDs, #last three stations all NAs?
# make new factors out of date data
aq$yrmonth <- as.factor(paste(year(aq$date),month(aq$date),sep="-"))
aq$year <- as.factor(year(aq$date))
aq$month <- as.factor(month(aq$date))
aq$hour <- as.factor(hour(aq$date))

# prove 12:14 have all NAs with summary, shows all NAs for those three, but when using dplyr they aren't?
lapply(split(aq[, 3:14], aq$Type), summary, na.rm=T)

## TIDY DATA
# new df - make station columns turn into rows, drop three stations that are all NAs
a <- aq %>%
	gather(station, conc, 3:11) %>%
	rename(chem = Type) %>%
	select(date, station, chem, conc)

a$station <- as.factor(a$station)

## ANALYSIS
# number of missing obs (31%)
sum(is.na(a$conc))/length(a$conc)
# number of obs for each Type
lapply(split(aq[, 3:12], aq$Type), function(x) sum(!is.na(x)))
# how many obs per station, showing 0 non NAs for El Condado?
apply(aq[, 3:12], 2, function(x) sum(!is.na(x)))

# make summary of data by each, drop NAs
a[!is.na(a$conc),] %>% 
	group_by(station, chem) %>%
	summarize(mean_conc = mean(conc), max_conc = (max(conc)), n = n()) %>%
	arrange(chem, desc(mean_conc))

# row means for each
aq$mean <- apply(aq[, 3:14], 1, mean, na.rm = T)

# when they are active
a[!is.na(a$conc),] %>% 
	group_by(station) %>%
	summarize(start = date[1], end = date[n()])


# Then we should count daily exceedances for each sensor and the average. 
# make category for each group of exceedances

# CO need 8 hour avg (ug/m3), units different from legis? max value is 11.7 from Carapungo but lowest legislated value is 15000
a[!is.na(a$conc),] %>% 
	filter(chem == "CO") %>%
	mutate(CO.8 = rollmean(x = conc, 8, align = "right", fill = NA)) %>% 
	group_by(station) %>% 
	summarize(Alert_ex = sum(conc > 1.5E4) , Alarm_ex = sum(conc > 3E4), Emergy_ex = sum(conc > 4E4))

# O3 avg in 8 hours
a[!is.na(a$conc),] %>% 
	filter(chem == "O3") %>%
	mutate(O3.8 = rollmean(x = conc, 8, align = "right", fill = NA)) %>%
	group_by(station) %>%
	summarize(Alert_ex = sum(conc > 2E2), Alarm_ex = sum(conc > 4E2), Emergy_ex = sum(conc > 6E2))

# PM 2.5 in 24 hours
a[!is.na(a$conc),] %>% 
	filter(chem == "PM25") %>%
	mutate(PM25.24 = rollmean(x = conc, 24, align = "right", fill = NA)) %>%
	group_by(station) %>%
	summarize(Alert_ex = sum(conc>1.5E2), Alarm_ex = sum(conc>2.5E2))

# SO2 in 24 hours
a[!is.na(a$conc),] %>% 
	filter(chem == "CO") %>%
	mutate(SO2.24 = rollmean(x = conc, 24, align = "right", fill = NA)) %>%
	group_by(station) %>%
	summarize(Alert_ex = sum(conc>2E2), Alarm_ex = sum(conc>1E3), Emergy_ex = sum(conc>1.8E3))


## PLOTTING
# histogram of dates for each sensor
ggplot(a, aes(x = date)) + 
	geom_histogram(bins=98) + #8yr*12mo 
	facet_wrap(~station)

# histogram facetting by sensor for each month
a %>% 
	mutate(month = month(date)) %>%
	ggplot(aes(x = month)) + 
	geom_histogram() + 
	facet_wrap(~station)

aq_by_hour <- a[!is.na(a$conc),] %>% 
		filter(chem == "PM25")%>%
		mutate(hour = as.factor(hour(date))) %>%
		aggregate(cbind(chem, conc) ~ hour, 
			  data = ., mean)
	
aq_by_month <- a[!is.na(a$conc),] %>% 
		filter(chem == "PM25")%>%
		mutate(yrmonth = as.factor(paste(year(date),month(date),sep="-"))) %>%
		aggregate(cbind(chem, conc) ~ yrmonth, 
			  data = ., mean)

#aq_2_2016 <- a[!is.na(a$conc),] %>% 
#		filter(chem == "PM25")%>%
#		mutate(hour = as.factor(hour(date))) %>%
#		aggregate(cbind(chem, conc) ~ hour, 
#                       data = date > "2016-02-01" & aq$date < "2016-03-01", mean)

year <- levels(a$year)
month <- levels(a$month)

# what is difference between pm2.5 level and concentration in beijing data?
aq_monthly_by_hour <- a[!is.na(a$conc),] %>% 
		filter(chem == "PM25")%>%
		mutate(year = as.factor(year(date)), month = as.factor(month(date)), hour = as.factor(hour(date))) %>%
		aggregate(cbind(chem, conc) ~ year+month+hour, 
			data = ., mean)
# radial plots
par(mfrow = c(1,3), mar = c(4,3,1,1))
polar.plot(mean(aq_by_hour$conc),
           start = 90, # move 00 to top
           clockwise = T,
           rp.type = "polygon", # connect 23 to 00
           line.col = "blue", 
           show.grid.labels = 1, # (1-4) 1 = move labels to vertical axis on bottom
           labels = aq_by_hour$hour, # outside labels
           label.pos = seq(0,360, by = 15), 
           radial.lim = c(0, 50), # defaults to min and max
           # main = paste("Mean PM 2.5 and Concentration", "at each Hour in Beijing", sep = "\n"))
           main = "Mean PM2.5 and Concentration at each Hour")
polar.plot(aq_by_hour$conc, 
           start = 90, 
           clockwise = T, 
           rp.type = "polygon",
           line.col = "red", 
           show.grid.labels = 1,
           labels = aq_by_hour$hour,
           label.pos = seq(0,360, by = 15),
           radial.lim = c(0, max(aq_by_hour$conc)),
           add = TRUE)
legend("bottomright", lty = 1, col = c("blue", "red"), 
       legend = c("PM2.5", "Concentration"),
       box.lwd = 0)
###########################################################################
#polar.plot(aq_by_hour$PM2.5.level,
#           start = 90, # move 00 to top
#           clockwise = T,
#           rp.type = "polygon", # connect 23 to 00
#           line.col = "blue", 
#           show.grid.labels = 1, # (1-4) 1 = move labels to vertical axis on bottom
#           labels = aq_by_hour$hour, # outside labels
#           label.pos = seq(0,360, by = 15), 
#           radial.lim = c(0, 250),
           # main = paste("Mean PM 2.5 and Concentration", "at each Hour in Beijing", sep = "\n"))
#           main = "Monthly Mean PM2.5 at each Hour")
#for (i in year){
#  for (j in month){
#    polar.plot(aq_monthly_by_hour$PM2.5.level[aq_monthly_by_hour$month == j & 
#                                                aq_monthly_by_hour$year == i], 
#               start = 90, 
#               clockwise = T, 
#               rp.type = "polygon",
#               line.col = "lightgrey", 
#               show.grid.labels = 1,
#               labels = aq_monthly_by_hour$hour,
#               label.pos = seq(0,360, by = 15),
#               radial.lim = c(0, 250),
#               lwd = 0.2,
#               add = TRUE)
#    }
#  }

#polar.plot(aq_by_hour$PM2.5.level,
#           start = 90, # move 00 to top
#           clockwise = T,
#           rp.type = "polygon", # connect 23 to 00
#           line.col = "blue", 
#           show.grid.labels = 1, # (1-4) 1 = move labels to vertical axis on bottom
#           labels = aq_by_hour$hour, # outside labels
#           label.pos = seq(0,360, by = 15), 
#           radial.lim = c(0, 250), # defaults to min and max
#           add = TRUE)
#polar.plot(aq_monthly_by_hour$PM2.5.level[aq_monthly_by_hour$month == "2" & aq_monthly_by_hour$year == "2016"], 
#           start = 90, 
#           clockwise = T, 
#           rp.type = "polygon",
#           line.col = "green", 
#           show.grid.labels = 1,
#           labels = aq_monthly_by_hour$hour,
#           label.pos = seq(0,360, by = 15),
#           radial.lim = c(0, max(aq_by_hour$PM2.5.level)),
#           add = TRUE)
#legend("bottomright", lty = 1, col = c("lightgrey", "blue", "green"), 
#       legend = c("PM2.5 level each month", "Mean", "Feb 2016"),
#       box.lwd = 0)
###########################################################################
#polar.plot(aq_by_hour$Concentration,
#           start = 90, # move 00 to top
#           clockwise = T,
#           rp.type = "polygon", # connect 23 to 00
#           line.col = "blue", 
#           show.grid.labels = 1, # (1-4) 1 = move labels to vertical axis on bottom
#           labels = aq_by_hour$hour, # outside labels
#           label.pos = seq(0,360, by = 15), 
#           radial.lim = c(0, 250),
#           # main = paste("Mean PM 2.5 and Concentration", "at each Hour in Beijing", sep = "\n"))
#           main = "Monthly Mean Concentration at each Hour")
#for (i in year){
#  for (j in month){
#    polar.plot(aq_monthly_by_hour$Concentration[aq_monthly_by_hour$month == j & 
#                                                aq_monthly_by_hour$year == i], 
#               start = 90, 
#               clockwise = T, 
#               rp.type = "polygon",
#               line.col = "lightgrey", 
#               show.grid.labels = 1,
#               labels = aq_monthly_by_hour$hour,
#               label.pos = seq(0,360, by = 15),
#               radial.lim = c(0, 250),
#               lwd = 0.2,
#               add = TRUE)
#  }
#}

#polar.plot(aq_by_hour$Concentration,
#           start = 90, # move 00 to top
#           clockwise = T,
#           rp.type = "polygon", # connect 23 to 00
#           line.col = "red", 
#           show.grid.labels = 1, # (1-4) 1 = move labels to vertical axis on bottom
#           labels = aq_by_hour$hour, # outside labels
#           label.pos = seq(0,360, by = 15), 
#           radial.lim = c(0, 250), # defaults to min and max
#           add = TRUE)
#polar.plot(aq_monthly_by_hour$Concentration[aq_monthly_by_hour$month == "2" & aq_monthly_by_hour$year == "2016"], 
#           start = 90, 
#           clockwise = T, 
#           rp.type = "polygon",
#           line.col = "black", 
#           show.grid.labels = 1,
#           labels = aq_monthly_by_hour$hour,
#           label.pos = seq(0,360, by = 15),
#           radial.lim = c(0, max(aq_by_hour$PM2.5.level)),
#           add = TRUE)
#legend("bottomright", lty = 1, col = c("lightgrey", "red", "black"), 
#       legend = c("PM2.5 con. each month", "Mean", "Feb 2016"),
#       box.lwd = 0)
#```


### Mean PM2.5 Level by Month
#```{r}
#aq_by_month <- aq_by_month %>%
#    mutate(yrmonth =  factor(yrmonth, levels = yrmonth_order)) %>%
#   arrange(yrmonth)
#plot(aq_by_month$PM2.5.level,
#     type = "b",
#     axes = FALSE,
#     xlab = "Year-Month",
#     ylab = "PM2.5",
#     main="Mean PM 2.5 Level by Month",
#     ylim = c(0,250),
#     pch = 16,
#     col = "grey")
#  axis(1, at= seq(1,73,by=2), 
#       tck = FALSE,
#       labels = FALSE)
#  text(seq(1,73,by=2), par("usr")[3]-0.5, 
#       srt = 60, adj= 1, xpd = TRUE,
#       labels = paste(levels(aq_by_month$yrmonth)[seq(1,73,by=2)]), 
#       cex=0.8)
#  axis(2, at= seq(0,(max(aq_by_month$PM2.5.level)+50),by=50),
#       tck = 0, las = 1,
#       labels = seq(0,(max(aq_by_month$PM2.5.level)+50),by=50))
#  par(xpd = FALSE)
#  grid()
#   points(x = aq_by_month$yrmonth[aq_by_month$yrmonth =="2016-2"],
#        y = min(aq_by_month$PM2.5.level),
#        col = "red",
#        pch = 16)
#   points(x = aq_by_month$yrmonth[aq_by_month$yrmonth =="2011-1"],
#         y = aq_by_month$PM2.5.level[aq_by_month$yrmonth=="2011-1"],
#         col = "blue",
#         pch = 16)
#   text(x = aq_by_month$yrmonth[aq_by_month$yrmonth =="2015-10"],
#       y = min(aq_by_month$PM2.5.level)-20,
#       paste("PM2.5 = ", round(min(aq_by_month$PM2.5.level),2)," in Feb 2016", sep = "\n"),
#       adj = c(0,1),
#       offset = c(0,-2))
#   text(x = aq_by_month$yrmonth[aq_by_month$yrmonth =="2011-2"],
#       y = aq_by_month$PM2.5.level[aq_by_month$yrmonth=="2011-1"]-20,
#       paste("PM2.5 = ", round(aq_by_month$PM2.5.level[aq_by_month$yrmonth=="2011-1"],2), 
#             "in Jan 2011", sep = "\n"),
#       adj = c(0,1))
#```


############################################################
# Interpolation here:
############################################################

library(ggplot2)
library(gstat)
library(sp)
library(maptools)

spaq <- aq[1:9]

Cotocollao <- c( -0.1077777, -78.49722, 2739)
Carapungo <- c(-0.098333, -78.44722, 2660)
Belisario <- c( -0.18, -78.49, 2835)
Jipijapa <- c( -0.16, -78.48, 2781)
El.Camal <- c( -0.25, -78.51,2840 )
Centro <- c( -0.22, -78.51, 2820 )
Guamani <- c(-0.3308333 , -78.551388, 3066)

dat <- data.frame(t(spaq[spaq$Type=="PM25" & spaq$yyyy.mm.dd.hh=="2013-Abr-5-5",3:9]))
test_sp <- SpatialPointsDataFrame(cbind(
                      c(Cotocollao[2],Carapungo[2], Belisario[2], Jipijapa[2], El.Camal[2], Centro[2], Guamani[2]),
                       c(Cotocollao[1],Carapungo[1],Belisario[1], Jipijapa[1],El.Camal[1], Centro[1], Guamani[1])),
                       data=dat)
plot(test_sp)
test_sp@data[is.na(test_sp@data)] <- mean(na.omit(test_sp@data))
test_df <- as.data.frame(test_sp)
names(test_df) <- c("X176934","x","y")

x.range <- as.numeric(c(-78.8, -78.3))  # min/max longitude of the interpolation area
y.range <- as.numeric(c(-0.5, 0))  # min/max latitude of the interpolation area

grd <- expand.grid(x = seq(from = x.range[1], to = x.range[2], by = 0.01), 
                   y = seq(from = y.range[1], to = y.range[2], by = 0.01))  # expand points to grid
coordinates(grd) <- ~x + y
gridded(grd) <- TRUE

plot(grd, cex = 1.5, col = "grey")
points(test_df$y~test_df$x, pch = 1, col = "red", cex = 1)


idw <- idw(formula = X176934) ~ 1, locations = test_sp, 
           newdata = grd)  # apply idw model for the data

idw.output = as.data.frame(idw)  # output is defined as a data table
names(idw.output)[1:3] <- c("lon", "lat", "var1.pred")  # give names to the modelled variables

ggplot() + geom_tile(data = idw.output, aes(x = long, y = lat, fill = var1.pred)) + 
    geom_point(data = test_df, aes(x = x, y = y), shape = 21, 
             colour = "red")

#quito_contour <- readShapePoly("C:/.shp")
#quito_contour <- fortify(quito_contour, region = "name")


#ggplot() + geom_tile(data = idw.output, alpha = 0.8, aes(x = long, y = lat, 
#                                                         fill = round(var1.pred, 0))) + scale_fill_gradient(low = "cyan", high = "orange") + 
#  geom_path(data = quito_contour, aes(long, lat, group = group), colour = "grey") + 
#  geom_point(data = test_df, aes(x = lon, y = lat), shape = 21, 
#             colour = "red") + labs(fill = "PM 2.5 Concentration", title = "PM 2.5 Concentration in Quito, ")
#
