
#' @parseRecords
#' @title Read in JSON data from business.json and parse into table with fields
# @author Gene Leynes
#' 
#' @param infile    Full path and filename to business.json file
#' @param ...       Additional parameters passed to parseRecord
#' 
#' @return          A data.table object based on the business.json input
#' 
#' @description     \code{parseRecords} parses a json document using 
#'                  \code{RJSONIO} and passes each record to \code{parseRecord} 
#'                  for further processing.
#'                  
#'                  The resulting table for each record are joined into a 
#'                  single table, which can then be used in machine learning 
#'                  models or statistical analysis. The input must be a 
#'                  specialized JSON document based on the format described in 
#'                  https://github.com/Chicago/sdp-business.json
#'                  
#'                  
#' 
#' @examples
#'     # parseRecords("extdata/examp_mod.json")
#' 
#' @export


parseRecords <- function(infile, ...){
    require(RJSONIO)
    
    recs <- RJSONIO::fromJSON(infile)
    recsParsed <- lapply(recs, parseRecord, ...)
    recsParsed <- rbindlist(recsParsed)
    return(recsParsed)

}

if(FALSE) {
    ## Initialize
    rm(list = ls())
    library(data.table)
    
    ## Load package functions
    geneorama::sourceDir("R")
    
    ## load sample
    recs <- RJSONIO::fromJSON("extdata/examp_mod.json")
    parseRecords("extdata/examp_mod.json")
    
}

