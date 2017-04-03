
parseRecord <- function(rec,
                        evalDays = c(90, 365, 365 * 2),
                        inspectionType = "foodInspections",
                        targetFieldName = "result",
                        targetCriteria = "=='FAIL'"){
    require(data.table)
    
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



