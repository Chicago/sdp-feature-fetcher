#' plenarioDatadump
#' 
#' Retreive event data from plenar.io
#' 
#' @param dataset            Dataset name in plenar.io, e.g. 
#'                           "crimes_2001_to_present"
#' @param filter             The text of the filter or filters to apply to the 
#'                           HTTP GET request issued to plenar.io, e..g 
#'                           "primary_type=ARSON"
#' @param event_window       A vector of two strings in YYYY-MM-DD format that 
#'                           indicate the start and end dates to retreive.
#' 
#' @return          A data.table object based on the parsed record input
#' 
#' @author Gene Leynes \email{gene.leynes@@cityofchicago.org}
#' 
#' @description      Returns a tabular dataset of events.
#' 
#' @examples
#'     # 
#' 
# @importFrom data.table
#' @export
#' 

plenarioDatadump <- function(dataset, 
                             filter = "", 
                             event_window){
    
    require(httr)
    require(jsonlite)
    
    point_date <- NULL
    
    if(!is.null(filter) && filter != ""){
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
