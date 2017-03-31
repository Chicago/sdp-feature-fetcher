getDensity <- function(records,
                        events,
                        datasetname,
                        filter = NULL,
                        daysback = 365,
                        h = c(.01, .01),
                        return_events = FALSE){
    
    require(data.table)
    require(MASS)
    
    ## Calculate event timeframe for data acquisition
    ## Use maximum of daysback to get maximum records needed to avoid future calls
    event_window <- records[ , c(min(date) - daysback, 
                                 max(date))]
    
    ## Download event data from plenario
    events <- plenarioDatadump(dataset = datasetname,
                                filter = filter, 
                                event_window = event_window)
    
    ## Create index values for pages
    N <- nrow(records)
    page_limit <- 150
    START_ROWS <- seq(1, N, page_limit)
    END_ROWS <- c(seq(1, N, page_limit)[-1] - 1, N)
    II <- mapply(`:`, START_ROWS, END_ROWS)
    
    ## Create an index
    records[ , i := .I]
    
    ## Within each processing block, for each Inspection_ID, 
    ## Calculate the KDE for that inspection based on citywide Lat / Lon values
    ## for whatever event. 
    ret <- rbindlist(lapply(II, function(ii) {
        foverlaps(    
            x = records[i = ii, 
                        j = list(i,
                                 longitude,
                                 latitude), 
                        keyby = list(start = date - daysback, 
                                     end = date)],
            y = events[i = TRUE, 
                       j = list(longitude, 
                                latitude),
                       keyby = list(start = point_date,  
                                    end = point_date)],
            type = "any")[ , kde(new = c(i.longitude[1], 
                                         i.latitude[1]), 
                                 x = longitude, 
                                 y = latitude, 
                                 h = h),
                           keyby = i]}))
    
    ## Set the names and return the object
    setnames(ret, "V1", "z")
    if(return_events){
        ret <- list(density = ret,
                    events = events)
    }
    return(ret)
}
