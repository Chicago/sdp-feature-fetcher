shift <- function(x, offset = 1, pad = NA) {
    r <- (1 + offset):(length(x) + offset)
    r[r<1] <- NA
    ans <- x[r]
    ans[is.na(ans)] <- pad
    return(ans)
}
