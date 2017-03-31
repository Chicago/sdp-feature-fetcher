

## Initialize
rm(list = ls())
library(data.table)

## Load package functions
geneorama::sourceDir("R")

## load sample
recs <- parseRecords(RJSONIO::fromJSON("doc/examp_mod.json"))

recs
densCrime <- getDensity(records = recs[ , list(date = actionDate, longitude, latitude)], 
                        datasetname = "crimes_2001_to_present", 
                        filter = "primary_type=ARSON",
                        daysback = 365,
                        h = .01,
                        return_events = FALSE)
densSanitation <- getDensity(records = recs[ , list(date = actionDate, longitude, latitude)], 
                             datasetname = "311_service_requests_sanitation_code_complaints", 
                             daysback = 365,
                             h = .01,
                             return_events = FALSE)
densGarbage <- getDensity(records = recs[ , list(date = actionDate, longitude, latitude)], 
                          datasetname = "311_service_requests_garbage_carts", 
                          daysback = 365,
                          h = .01,
                          return_events = FALSE)

recs[ , densCrime := densCrime[ , z]]
recs[ , densCrime := densSanitation[ , z]]
recs[ , densCrime := densGarbage[ , z]]

recs

