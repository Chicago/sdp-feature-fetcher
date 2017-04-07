
if(FALSE){


##------------------------------------------------------------------------------
## ORIGINAL EXAMPLE
##------------------------------------------------------------------------------

url <- paste0("http://plenar.io/v1/api/detail/?dataset_name=food_inspections&",
              "shape=boundaries_neighborhoods&boundaries_neighborhoods__filter=",
              "{%22op%22:%20%22eq%22,%20%22col%22:%20%22pri_neigh%22,%20%22val%22:%20%22Logan%20Square%22}")
data <- httr::GET(url)
str(data)
contentdata <- httr::content(data, as = "text")
contentdata
str(jsonlite::fromJSON(contentdata))

##------------------------------------------------------------------------------
## LIMIT EXAMPLE
## (MAX ROWS ARE 10000)
##------------------------------------------------------------------------------

url <- paste0("http://plenar.io/v1/api/detail/?dataset_name=food_inspections&",
              "shape=boundaries_neighborhoods&boundaries_neighborhoods__filter=",
              "{%22op%22:%20%22eq%22,%20%22col%22:%20%22pri_neigh%22,%20%22val%22:%20%22Logan%20Square%22}&",
              "limit=10000")
url
data <- httr::GET(url)
contentdata <- httr::content(data, as = "text")
str(jsonlite::fromJSON(contentdata))


##------------------------------------------------------------------------------
## GET ALL DATA SETS
##------------------------------------------------------------------------------
datasets <- httr::GET("http://plenar.io/v1/api/datasets")
datasets <-  httr::content(datasets, as = "text")
datasets <- jsonlite::fromJSON(datasets)
str(datasets, 2)
ii <- grep("data.cityofchicago.org", datasets$objects$source_url)
datasets$objects$dataset_name[ii]

## GET CRIME META DATA
crimemeta <- httr::GET("http://plenar.io/v1/api/datasets?dataset_name=crimes_2001_to_present")
crimemeta <-  httr::content(crimemeta, as = "text")
crimemeta <- jsonlite::fromJSON(crimemeta)
crimemeta


##------------------------------------------------------------------------------
## WNV EXAMPLE
##------------------------------------------------------------------------------

west_nile_virus_wnv_mosquito_test_results
url <- paste0("http://plenar.io/v1/api/datadump/?",
              "dataset_name=west_nile_virus_wnv_mosquito_test_results&",
              "obs_date__ge=2000-01-01") # needs date
data <- httr::GET(url)
contentdata <- httr::content(data, as = "text")
data <- jsonlite::fromJSON(contentdata)
str(data)



##------------------------------------------------------------------------------
## CRIME BURGLARY ONLY
##------------------------------------------------------------------------------
url <- paste0("http://plenar.io/v1/api/datadump/?",
              "dataset_name=crimes_2001_to_present&",
              "primary_type=BURGLARY&",
              "obs_date__ge=2017-03-01")
url
data <- httr::GET(url)
data
contentdata <- httr::content(data, as = "text")
contentdata <- jsonlite::fromJSON(contentdata)
str(contentdata)
table(contentdata$features$properties[ , "primary_type"])

}
