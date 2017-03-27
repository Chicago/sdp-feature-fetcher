
rm(list = ls())

# library(jsonlite)

# str(jsonlite::fromJSON("../sdp-business.json/ResultSet.json"), 2)
# jsonlite::fromJSON("../sdp-business.json/ResultSet.json")


str(RJSONIO::fromJSON("../sdp-business.json/ResultSet.json"), 2)
str(RJSONIO::fromJSON("../sdp-business.json/ResultSet.json")[[1]], 2)
RJSONIO::fromJSON("../sdp-business.json/ResultSet.json")

recs <- RJSONIO::fromJSON("../sdp-business.json/ResultSet.json")[[1]]

str(rec)

rec$legalName
rec$doingBusinessAsName
rec$accountNumber
rec$address["fullAddress"]
rec$metadata
rec$coordinates
rec$businessLicenses
rec$foodInspections


rec <- jsonlite::fromJSON("../sdp-business.json/ResultSet.json")
str(rec)


# bus <- readRDS("../food-inspections-evaluation/DATA/bus_license.Rds")
# colnames(bus)




