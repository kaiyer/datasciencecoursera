#
library(plyr)
library(dplyr)
library(ggplot2)
library(XML)
library(reshape2)
library(zoo)

eiadata <- function() {
  # monthly time series of nat. gas and diesel prices
  urlg <- "http://www.eia.gov/dnav/ng/hist/n3035us3M.htm"
  urld <- "http://www.eia.gov/dnav/pet/hist/LeafHandler.ashx?n=pet&s=emd_epd2d_pte_nus_dpg&f=m"
  
  tablesg <- readHTMLTable(urlg)
  tablesd <- readHTMLTable(urld)
  # extract the html table as data frame
  rawtblg <- tablesg[[6]]
  rawtbld <- tablesd[[7]]
  # clean out non-numeric values
  rawtblg$Year <- as.numeric(gsub("[^0-9.]","",rawtblg$Year))
  rawtbld$Year <- as.numeric(gsub("[^0-9.]","",rawtbld$Year))
  # remove rows in which Year is NA
  rawtblg <- rawtblg[is.na(rawtblg$Year)==FALSE,]
  rawtbld <- rawtbld[is.na(rawtbld$Year)==FALSE,]
  
  # now melt data and continue cleaning data
  
  rawtblg <- melt(rawtblg, id=c("Year"))
  names(rawtblg)[2] <- c("Month")
  rawtblg$value <- as.numeric(rawtblg$value)
  sortnames <- c("Year", "Month")
  rawtblg <- rawtblg[do.call("order", rawtblg[sortnames]),]
  variable <- rep("ngprice",dim(rawtblg)[1])
  rawtblg <- cbind(rawtblg, variable)
  
  rawtbld <- melt(rawtbld, id=c("Year"))
  names(rawtbld)[2] <- c("Month")
  rawtbld$value <- as.numeric(rawtbld$value)
  rawtbld <- rawtbld[do.call("order", rawtbld[sortnames]),]
  variable <- rep("dieselprice",dim(rawtbld)[1])
  rawtbld <- cbind(rawtbld, variable)
  
  # now combine the two data frames
  dflist <- list(rawtblg, rawtbld)
  tbl.df <- rbind.fill(dflist)
  # clean NA
  # tbl.df
  tbl.df <- tbl.df[!is.na(tbl.df$value),]
  #now add CalDate column
  yrmon <- paste(tbl.df$Year,"-",tbl.df$Month,sep="")
  caldate <- as.Date(as.yearmon(yrmon,"%Y-%b"))
  tbl.df$caldate <- caldate
  
  # find min and max dates across the 2 variables
  caldate.summary <- tbl.df %>% group_by(variable) %>% summarise(mindt=min(caldate), maxdt=max(caldate))
  mindt <- max(caldate.summary$mindt)
  maxdt <- min(caldate.summary$maxdt)
  # now filter tbl.df to just the required rows
  tbl.df <- tbl.df[tbl.df$caldate>=mindt & tbl.df$caldate<=maxdt, ]
  tbl.df <- data.frame(caldate=tbl.df$caldate, variable=tbl.df$variable, value=tbl.df$value)
  
  # now plot data
  #ggplot(tbl.df, aes(caldate, value)) +
  #  geom_line(aes(color=variable)) 
  tbl.df
}