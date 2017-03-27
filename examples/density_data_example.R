
rm(list = ls())

library(geneorama)
library(data.table)
library(MASS)

source("density_example.R", local = TRUE)
source("R/plenario_datadump.R")
source("R/kde.R")
source("R/interpolate_xy.R")
source("R/get_density.R")

dens <- get_density(records = records, 
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

