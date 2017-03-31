
rm(list = ls())

library(geneorama)
library(data.table)
library(MASS)
library(httr)
library(jsonlite)

source("examples/density_example.R", local = TRUE)
source("R/plenarioDatadump.R")
source("R/kde.R")
source("R/interpolateXY")
source("R/getDensity.R")

dens <- getDensity(records = records, 
                   datasetname = "crimes_2001_to_present", 
                   filter = "primary_type=BATTERY",
                   daysback = 365,
                   h = .01,
                   return_events = TRUE)
records
dens

records[['dens']] <- dens[['density']][['z']]

# plot(dens$density, records$z)
# plot(records$longitude, records$latitude)
# records[order(latitude, longitude, decreasing = F)][,diff(latitude)]
# records[order(longitude, latitude, decreasing = F), contourLines(longitude, latitude, dens)]
# 
# 
# xyz <- records[ , list(x = longitude, y = latitude, z)]
# xyz <- xyz[order(y, x)]
# xyz[ , diff(y)]
# contour(xyz)

