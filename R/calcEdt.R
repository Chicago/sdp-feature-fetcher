calcEdt <- function(vec){
    nc <- length(vec)
    edt <- matrix(NA, nc, nc)
    for(i in 2:nc){
        edt[i, 1:(i-1)] <- vec[1:(i-1)]
    }
    return(edt)
}


## Original code as matrix rather than vector
# edt <- dt[ , targetBool]
# nc <- nrow(dt)
# edt <- matrix(NA, nc, nc)
# for(i in 2:nc){
#     edt[i, 1:(i-1)] <- dt[1:(i-1) , targetBool]
# }

