#' parseRecord
#' Read in JSON data from business.json and parse into table with fields
#' 
#' @param rec                Single business record from business.json file 
#'                           formatted as a list (full list a la RJSONIO 
#'                           format, not jsonlite format)
#' @param evalDays           A integer vector that specifies the days at which 
#'                           you want to calculate trailing counts of the 
#'                           target observation. Both counts and counts where 
#'                           the criteria is true (described in 
#'                           targetCriteria) are tabulated. For example, a 
#'                           vector of c(60, 365, 3650) will calculate number 
#'                           of inspections and number of failed inspections in
#'                           the past 60 days, 1 year, and roughly 10 years.
#' @param inspectionType     The the name of the top level list item in the 
#'                           JSON document that contains the event of interest.
#'                           This is the "unit of analysis" for each record. In 
#'                           the sample data this field is "foodInspections".
#' @param targetFieldName    The name of the field that describes the outcome
#'                           that you are modeling. In the sample data this
#'                           it's a field called "result" that takes on the 
#'                           values "PASS" or "FAIL".
#' @param targetCriteria     This controls how the binary results are 
#'                           calculated on the target. This field is code that 
#'                           gets evaluated on the values in the target, to 
#'                           create boolean results. In this example the 
#'                           criteria is "==FAIL". This string is appended to 
#'                           the strings contained in the targetFieldName and
#'                           evaluated so that FAIL will appear as TRUE and 
#'                           anything else will be FALSE. It is also possible
#'                           to use numeric criteria for numeric targets, such
#'                           as ">235" or "<1e6".
#' 
#' @return          A data.table object based on the parsed record input
#' 
#' @author Gene Leynes \email{gene.leynes@@cityofchicago.org}
#' 
#' @description     Creates tabular data for use in machine learning models or 
#'                  statistical analysis. The input must be a specialized 
#'                  JSON document based on the format described in 
#'                  https://github.com/Chicago/sdp-business.json
#'                  
#'                  \code{parseRecord} parses a single record after it has been
#'                  converted to a list object using \code{RJSONIO}
#' 
#' @examples
#'     # parseRecord(RJSONIO::fromJSON("extdata/examp_mod.json")[[1]])
#' 
#' @export parseRecord
#' 

parseRecord <- function(rec,
                        evalDays = c(90, 365, 365 * 2),
                        inspectionType = "foodInspections",
                        targetFieldName = "result",
                        targetCriteria = "=='FAIL'"){
    require(data.table)
    
    actionDate <- NULL
    target <- NULL
    targetBool <- NULL
    earliestStartDate <- NULL
    ageAtActionDate <- NULL
    
    ## Get field index values and field labels
    iInspectionIndex <- which(sapply(rec$metadata, `[[`, "sourceName") == inspectionType)
    actionDateLabel <- rec$metadata[[iInspectionIndex]][["actionDate"]]
    
    ## Construct basic record of inspections
    dt <- data.table(legalName = rec$legalName,
                     doingBusinessAsName = rec$doingBusinessAsName,
                     accountNumber = rec$accountNumber,
                     fullAddress = rec$address["fullAddress"],
                     latitude = rec$coordinates$latLon['latitude'],
                     longitude = rec$coordinates$latLon['longitude'],
                     inspectionId = sapply(rec[[inspectionType]], `[[`, "id"),
                     actionDate = sapply(rec[[inspectionType]], `[[`, actionDateLabel),
                     target = sapply(rec[[inspectionType]], `[[`, targetFieldName))
    
    ## Convert date to POSIX date
    dt[ , actionDate := as.IDate(actionDate)]
    
    ##------------------------------------------------------------------------------
    ## Translate target to boolean
    ##------------------------------------------------------------------------------
    if(class(dt[ , target]) == "character"){
        ## quote values within target if character
        exprs <- paste0(dt[ , paste0("'", target, "'")], targetCriteria)
    } else {
        exprs <- paste0(dt[ , target], targetCriteria)
    }
    dt[ , targetBool := sapply(exprs, 
                               function(x) eval(parse(text=x)), 
                               USE.NAMES = FALSE)]
    
    ##------------------------------------------------------------------------------
    ## License Start Date and age at inspection
    ##------------------------------------------------------------------------------
    ## Ideally, if there were an identifier for the license within the inspection
    ## we would extract specific information about the license here. 
    
    ## Extract licenseStartDate
    LicenseStartDates <- as.IDate(sapply(rec$businessLicenses, 
                                         `[[`, 
                                         "licenseStartDate"))
    dt[ , earliestStartDate := min(LicenseStartDates)]
    
    ## Calculate age of business
    dt[ , ageAtActionDate := actionDate - earliestStartDate]
    dt
    
    ##------------------------------------------------------------------------------
    ## Triangle calculations
    ##------------------------------------------------------------------------------
    
    ## order dt by action date 
    ## ** VERY IMPORTANT TO KEEP THIS ORDER THROUGHOUT ALL TRIANGLE CALCULATIONS **
    dt <- dt[order(actionDate)]
    
    ## Date data triangle
    ddt <- distmat(dt[ , actionDate])
    
    ## Calculate the number of times that the event happened in past eval days
    for(d in evalDays){
        set(x = dt, 
            j = paste0("eventsPast", d,"days"), 
            value = apply(ddt <= d, 1, sum, na.rm = TRUE))
    }
    
    ## Event data triangle
    edt <- calcEdt(dt[ , targetBool])
    
    ## Calculate frequency of target event happening in past eval days
    for(d in evalDays){
        set(x = dt, 
            j = paste0("TargetEventsPast", d,"days"), 
            value = unname(apply(ddt <= d * edt, 1, sum, na.rm = TRUE)))
    }
    dt
    
}


if(FALSE){
    
    ## Initialize
    rm(list = ls())
    library(data.table)
    
    ## Load package functions
    geneorama::sourceDir("R")
    
    ## load sample
    rec <- RJSONIO::fromJSON("data/examp_mod.json")[[1]]
    # rec$metadata
    # rec$coordinates
    # rec$businessLicenses
    # rec$foodInspections
    
    ## Simulated function input
    # evalDays <- c(90, 365, 365 * 2)
    # inspectionType = "foodInspections"
    # targetFieldName <- "result"
    # targetCriteria <- "=='FAIL'"
    
    parseRecord(rec)
    
}



