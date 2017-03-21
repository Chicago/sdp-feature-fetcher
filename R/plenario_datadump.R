plenario_datadump <- function(dataset = "crimes_2001_to_present", 
                              filter = "", 
                              event_window){
    
    require(httr)
    require(jsonlite)
    
    if(filter != ""){
        filter <- paste0(filter, "&", collapse = "&")
    }
    
    url <- paste0("http://plenar.io/v1/api/datadump/?",
                  sprintf("dataset_name=%s&", dataset),
                  filter,
                  sprintf("obs_date__ge=%s&", event_window[1]),
                  sprintf("obs_date__le=%s", event_window[2]))
    cat("downloading: ", url, "\n")
    data <- httr::GET(url)
    if(httr::http_status(data)$category != "Success"){
        stop("http error")
    } else {
        contentdata <- httr::content(data, as = "text")
        contentdata <- jsonlite::fromJSON(contentdata)
        feats <- data.table(contentdata$features$properties)
        feats <- feats[ , point_date := as.IDate(point_date)][]
    }
    cat("Download complete\n")
    return(feats)
}
