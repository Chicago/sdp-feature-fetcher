

distmat <- function(vec){
    mat <- as.matrix(dist(vec, diag = T))
    nc <- length(vec)
    for(i in 1:nc){
        mat[i , i:nc] <- NA
    }
    return(mat)
}

