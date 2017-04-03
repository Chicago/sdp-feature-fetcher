
parseRecords <- function(recs){
    
    recsParsed <- lapply(recs, parseRecord)
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
    recs <- RJSONIO::fromJSON("data/examp_mod.json")
    
}

