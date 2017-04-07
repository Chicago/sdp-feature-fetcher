
if(FALSE){

## Initialize
rm(list = ls())
library(data.table)

## Load package functions
sapply(list.files("R", full.names = TRUE), source)

## load sample
recs <- parseRecords(infile = "extdata/examp_mod.json")

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
recs[ , densSanitation := densSanitation[ , z]]
recs[ , densGarbage := densGarbage[ , z]]

recs

}
