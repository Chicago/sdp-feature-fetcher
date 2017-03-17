
rm(list = ls())
source("density_example.R")


library(geneorama)
library(data.table)


# get_density <- function(records,
#                         datasetname,
#                         filter=NULL,
#                         days_back=365,
#                         days_back_to_exclude=14
# ){
#     
#     
#     
#     
#     
# }

library(maptools)
library(ggplot2)
library(MASS)
library(RColorBrewer)


## Calculate event timeframe for data acquisition
## Use maximum of days_back to get maximum records needed to avoid future calls
event_window <- records[ , c(min(date) - max(days_back), 
                             max(date))]


plenario_datadump <- function(dataset = "crimes_2001_to_present", 
                              filter = "", 
                              event_window){
    
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
        
    return(feats)
}

event_data <- plenario_datadump(filter = "primary_type=BATTERY", event_window=event_window)
event_data



inspections <- reactive({
    eval_time <- input$eval_time
    
    inspections <- DAT_MODEL[date > eval_time & date < (eval_time + 90) , 
                             list(y=LATITUDE, x=LONGITUDE, date, Unstamped)]
    inspections <- inspections[!is.na(x) & !is.na(y)]
    return(inspections)
    
})



event1 <- reactive({
    print("event1_start")
    
    window1 <- window1()
    event <- event()
    
    win <- window1
    event1 <- event[i = Date > win[1] & Date < win[2],
                    j = list(Primary_Type, x = Longitude, y = Latitude)]
    
    print("event1_end")
    return(event1)
})

event0 <- reactive({
    print("event0_start")
    
    window2 <- window2()
    event <- event()
    
    win <- window2
    event0 <- event[i = Date > win[1] & Date < win[2],
                    j = list(Primary_Type, x = Longitude, y = Latitude)]
    
    print("event0_end")
    return(event0)
})

dens_event1 <- reactive({
    print("dens_event1_start")
    
    nbins <- nbins()
    bandwidth <- bandwidth()
    event1 <- event1()
    prim_type <- prim_type()
    
    event1 <- event1[Primary_Type %in% prim_type, list(x,y)]
    
    dens_event1 <- kde2d(x = event1$x, 
                         y = event1$y, 
                         h = bandwidth, 
                         n = nbins, 
                         lims = LOC_RNG)
    print("dens_event_end")
    return(dens_event1)
})

dens_event0 <- reactive({
    print("dens_event0_start")
    
    nbins <- nbins()
    bandwidth <- bandwidth()
    event0 <- event0()
    prim_type <- prim_type()
    
    event0 <- event0[Primary_Type %in% prim_type, list(x,y)]
    
    dens_event0 <- kde2d(x = event0$x, 
                         y = event0$y, 
                         h = bandwidth, 
                         n = nbins, 
                         lims = LOC_RNG)
    print("dens_event0_end")
    return(dens_event0)
})

dens_event_comp <- reactive({
    print("dens_event_comp_start")
    density_normalized <- input$density_normalized
    
    dens_event_comp <- list(x = dens_event1()$x, 
                            y = dens_event1()$y, 
                            z = dens_event0()$z - dens_event1()$z)
    ## Normalize
    if(density_normalized){
        z <- dens_event_comp$z
        dens_event_comp$z <- (z - mean(z)) / sd(z)
    }
    
    print("dens_event_comp_end")
    return(dens_event_comp)
})

density_for_ggplot <- reactive({
    print("density_for_ggplot_start")
    
    mode <- mode()
    
    dens <- switch(mode,
                   "absolute"   = dens_event1(),
                   "difference" = dens_event_comp())
    
    ## Contour lines - Reshape and rename for ggplot
    density_for_ggplot <- data.table(z=melt(dens$z))
    setnames(density_for_ggplot, c("x", "y", "z"))
    density_for_ggplot[ , x:=dens$x[density_for_ggplot$x]]
    density_for_ggplot[ , y:=dens$y[density_for_ggplot$y]]
    
    print("density_for_ggplot_end")
    return(density_for_ggplot)
})


inspections_with_density <- reactive({
    
    print("inspections_with_density_start")
    
    mode <- input$mode
    dens <- switch(mode,
                   "absolute"   = dens_event1(),
                   "difference" = dens_event_comp())
    inspections <- inspections()
    
    ## Calculate inspection densities
    inspections_with_density <- inspections[
        , z := interpolate_xy(dens, x, y)$z][]
    
    print("inspections_with_density_end")
    
    return(inspections_with_density)
})

model <- reactive({
    print("model_start")
    
    inspections_with_density <- inspections_with_density()
    
    ## Calculate model results of inspection densities
    # m <- lm(Unstamped ~ z, insp)
    model <- glm(Unstamped ~ z, 
                 data = inspections_with_density, 
                 family = "binomial")
    
    print("model_end")
    
    return(model)
})

output$model_info <- renderUI({
    cwd <- getwd()
    prim_type <- prim_type()
    bandwidth <- bandwidth()
    nbins <- nbins()
    window1 <- window1()
    window2 <- window2()
    inspections <- inspections()
    event <- event()
    event0 <- event0()
    event1 <- event1()
    inspections_with_density <- inspections_with_density()
    model <- model()
    
    ## Print values, row numbers, date ranges, etc:
    model_txt <- paste(capture.output(summary(model)), collapse = "<br>")
    model_drng <- paste(range(inspections_with_density$date), collapse = " - ")
    model_nr <- nrow(inspections_with_density)
    event_drng <- paste(range(event$Date), collapse = " - ")
    event_nr <- nrow(event)
    event1_nr <- nrow(event1)
    event0_nr <- nrow(event0)
    event1_nrf <- nrow(event1[Primary_Type %in% prim_type])
    event0_nrf <- nrow(event0[Primary_Type %in% prim_type])
    win1 <- paste(window1, collapse = " - ")
    win2 <- paste(window2, collapse = " - ")
    
    ## HTML OUTPUT
    HTML(paste0(
        "MODEL INPUTS:", br(),
        "  CWD: ", cwd, br(),
        "  nbins: ", nbins, br(),
        "  Bandwidth: ", round(bandwidth, 5), br(),
        "  INSPECTIONS:    ", " (", model_drng, ") N=", model_nr,  br(),
        "  event UNIVERSE: ", " (", event_drng, ") N=", event_nr,  br(),
        "  event SUBSET T0:", " (", win1,       ") N=", event0_nr, " -> ", event0_nrf, br(),
        "  event SUBSET T1:", " (", win2,       ") N=", event1_nr, " -> ", event1_nrf, br(), "\n",
        "MODEL RESULTS (GLM)", "",
        model_txt))
})


