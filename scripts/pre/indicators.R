
library(pacman)
p_load(dplyr,magrittr,googlesheets,janitor, ggplot2, wesanderson)
source("https://raw.githubusercontent.com/janhove/janhove.github.io/master/RCode/sortLvls.R")

ind_raw <- gs_url("https://docs.google.com/spreadsheets/d/1FgRDGUizEoZnXi6GcjtY-HKuxHPXP78WMQx21XOIxzs/pubhtml?gid=444011284&single=true")
ind_raw <- gs_read(ind_raw, range=cell_rows(2:ind_raw$ws$row_extent))

ind <-  ind_raw %>%
  clean_names() %>%
  remove_empty_rows() %>%
  remove_empty_cols()  # %>%
 # mutate(hire_date = excel_numeric_to_date(hire_date),
 #        main_cert = use_first_valid_of(certification, certification_2)) %>%
 # select(-certification, -certification_2) # drop unwanted columns
ind <- ind[!is.na(ind$indicator),]
ind <- ind[!is.na(ind$primary_issue),]
ind$unit_sc <- gsub("small","Small",ind$unit_sc,fixed=TRUE)
ind$unit_of_analysis <- as.factor(ind$unit_of_analysis)
ind$unit_sc <- as.factor(ind$unit_sc)
ind$primary_issue[!is.na(ind$primary_issue) & ind$primary_issue=="Cross Sectoral"] <- "Green Economy"
ind$unit_of_analysis[!is.na(ind$unit_of_analysis) & ind$unit_of_analysis=="City"] <- "City limits"
ind$unit_of_analysis[!is.na(ind$unit_of_analysis) & ind$unit_of_analysis=="State"] <- "Regional"
ind$unit_of_analysis[!is.na(ind$unit_of_analysis) & ind$unit_of_analysis=="Multi-city"] <- "Regional"
ind$target_quality[!is.na(ind$target_quality) & ind$target_quality=="No target"] <- "No Target"
ind$target_quality <- as.factor(ind$target_quality)


glimpse(ind)
ind$target_quality <- as.factor(ind$target_quality)
ind$primary_issue <- as.factor(ind$primary_issue)
ind$target_quality[ind$target_quality == "No target"] <- "No Target"

#iss_equity <- select(ind$primary_issue,ind$equity) %>% 
#  crosstab(primary_issue,equity)
#iss_equity
#
#prim_iss <- select(ind$primary_issue) %>%
#  tabyl(primary_issue)

#Use the nifty function to sort the data frame by primary issue
ind$primary_issue <- sortLvlsByN.fnc(ind$primary_issue)


#################################
# Commence the plotting         #
#################################

#Use the nifty function to sort the data frame by primary issue
ind$primary_issue <- sortLvlsByN.fnc(ind$primary_issue)

# Issue frequency
ggplot(data=subset(ind, !is.na(primary_issue) ), 
       aes(primary_issue, fill=target_quality,na.rm=TRUE)) +
  geom_bar() + coord_flip() + 
  labs(list(title="Equity by Primary Issue",x="Primary Issue",y="Count")) + 
  theme_minimal() #+
  scale_fill_brewer(type = "qual", palette = , direction=-1)  +
  theme(legend.position="none")
#ggsave("frequency.pdf")

# Equity by primary issue
ggplot(data=subset(ind, !is.na(primary_issue) & !is.na(equity)), 
       aes(primary_issue, fill=equity, na.rm=TRUE)) +
  geom_bar() + coord_flip() +
  labs(list(#title="Equity Indicators by Primary Issue",
            x="Primary Issue",y="Count")) + 
  theme_minimal() 
ggsave("equity.pdf")

# Quality of Targets by Primary Issue
tgt_order <- c(4,1,2,3,5)
ind$target_quality <- sortLvls.fnc(ind$target_quality, tgt_order)
ind$primary_issue <- 

ggplot(data=subset(ind, !is.na(primary_issue) & !is.na(target_quality)), 
       aes(primary_issue, fill=target_quality, na.rm=TRUE)) +
  geom_bar() + coord_flip() + 
  labs(list(title="Quality of Targets by Primary Issue", x="Primary Issue", y="Percent")) + 
  theme_minimal() 
  #scale_fill_brewer(type = "qual", palette = 2)
#ggsave("targets.pdf")

# Cross-sectoral Issues
ind <- mutate(ind,cross_sector= ifelse(is.na(secondary),"No","Yes"))
ggplot(data=subset(ind, !is.na(primary_issue) & !is.na(target_quality)), 
       aes(primary_issue, fill=cross_sector, na.rm=TRUE)) +
  geom_bar(position="fill") + coord_flip() + 
  labs(list(title="Cross-sectoral Issues",x="Primary Issue",y="Percent")) + 
  theme_minimal() +
  scale_fill_brewer(type = "seq", palette = 5, direction = -1)
#ggsave("cross-sector.pdf")

# Unit of analysis
unit_order <- c(6,4,1,2,5,7,3)
ind$unit_of_analysis <- sortLvls.fnc(ind$unit_of_analysis, unit_order)
ggplot(data=subset(ind, !is.na(unit_of_analysis) & !is.na(equity)), 
       aes(unit_of_analysis, fill=equity, na.rm=TRUE)) +
  geom_bar() + coord_flip() + 
  labs(list(title="Unit of Analysis and Equity",x="Unit of Analysis",y="Count")) + 
  theme_minimal()
#ggsave("unit_of_analysis.pdf")

glimpse(ind)


mutate(ind, method.type = 
        ifelse(grepl("Single number as reported by WDI",methodology), 999,
        ifelse(grepl("Not specified",methodology), 999,
        ifelse(grepl("Self-reported by countries",methodology), 999,
        ifelse(grepl("Methodology of collecting data was not mentioned.",methodology), 999,
        ifelse(grepl("Overlaying to sets of data visualizations.",methodology), 999,
        ifelse(grepl("self-reported",methodology), 999, "PROCESS" ) )))))) 
ind$method.type
ind$methodology


table(na.omit(ind$unit_of_analysis))
table(na.omit(ind$unit_sc))

crosstab(ind$unit_sc,ind$equity)
crosstab(ind$unit_of_analysis,ind$equity)


na.omit(ind$indicator_description[ind$primary_issue=="Transportation"])
#ggsave("cross-sector.pdf")


############################################
# Print out a couple numbers for the paper #
############################################

# How many indicators for each primary issue?
sort(table(ind$primary_issue),decreasing = T)


# This isn't working... just estimate.
#gsub(pattern=" Indicator City ", 
#     replacement=" City Indicators ", 
#     x= ind$index)
sort(table(ind$index), decreasing = T)

# Equity indicators
sort(table(ind$equity), decreasing = T)
66+379

crosstab(ind$unit_sc,ind$equity, show_na = FALSE, percent = "row")

table(ind$unit_of_analysis)

levels(ind$index)

ind$data_source[!is.na(ind$data_source)]

unavailable <- c("Not published", "not applicable")

govt_data <- c("Census", "epa", "EPA, boston", "MassGIS", "American Community Survey",
               "Metropolitan Area Planning Council" , "California Air Resources Board (CARB)",
               "RESI, US EPA, TRI", "U.S. Energy Information", "USGS","City of Minneapolis")
               
other_provider <- c("cdp","dataforcities.org")
                    
bespoke <- c("self-reported", "survey", "interview","HFA National Progress","Hamududu&Killingtveit (2012)",
             "et al.")

length(grep(paste(govt_data,collapse="|"), 
            ind$data_source, ignore.case = T,value=TRUE))

length(grep(paste(unavailable,collapse="|"), 
            ind$data_source, ignore.case = T,value=TRUE))

length(grep(paste(bespoke,collapse="|"), 
            ind$data_source, ignore.case = T,value=TRUE))

length(grep(paste(other_provider,collapse="|"), 
            ind$data_source, ignore.case = T,value=TRUE))



