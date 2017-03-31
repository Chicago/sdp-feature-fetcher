

interpolate_xy <- function(grid, x, y) {
    
    ## You can find the x intervals and y intervals with this type of formula:
    xrng <- range(grid$x)
    xbins <- length(grid$x) -1
    yrng <- range(grid$y)
    ybins <- length(grid$y) -1
    
    if(any(x > xrng[2]) | any(x < xrng[1])){
        stop("some values of x fall outside the range")
    }
    if(any(y > yrng[2]) | any(y < yrng[1])){
        stop("some values of y fall outside the range")
    }
    
    ## If any points are at the max range, then subtract a small tolerance
    ## to make them fall into the highest bin.
    x[x == xrng[2]] <- x[x == xrng[2]] - 1e-9
    y[y == yrng[2]] <- y[y == yrng[2]] - 1e-9
    
    ## Determine the bin for x and y
    ix <- trunc( (x - min(xrng)) / diff(xrng) * (xbins)) + 1
    iy <- trunc( (y - min(yrng)) / diff(yrng) * (ybins)) + 1
    
    ## Simplistic interpolation on the z values in grid:
    z <- (grid$z[cbind(ix, iy)] + 
              grid$z[cbind(ix + 1, iy)] + 
              grid$z[cbind(ix, iy + 1)] + 
              grid$z[cbind(ix + 1, iy + 1)]) / 4
    
    
    ret <- list(x=x, y=y, ix=ix, iy=iy, z=z)
    
    return(ret)
    
}



if(FALSE){
    
    rm(list=ls())
    
    ## Example contour data
    grid_examp <- list(x = c(-87.727, -87.723, -87.719, -87.715, -87.711), 
                       y = c(41.836, 41.839, 41.843, 41.847, 41.851), 
                       z = (matrix(data = c(-3.428, -3.722, -3.061, -2.554, -2.362, 
                                            -3.034, -3.925, -3.639, -3.357, -3.283, 
                                            -0.152, -1.688, -2.765, -3.084, -2.742, 
                                            1.973,  1.193, -0.354, -1.682, -1.803, 
                                            0.998,  2.863,  3.224,  1.541, -0.044), 
                                   nrow = 5, ncol = 5)))
    
    ## Example values to look up by x and y:
    df_examp <- data.frame(x = c(-87.723, -87.712, -87.726, -87.719, -87.722, -87.722), 
                           y = c(41.84, 41.842, 41.844, 41.849, 41.838, 41.842), 
                           id = c("a", "b", "c", "d", "e", "f"),
                           stringsAsFactors = FALSE)
    ans <- interpolate_xy(grid_examp, df_examp$x, df_examp$y)
    
    contour(grid_examp)
    points(df_examp$x, df_examp$y, pch=df_examp$id, col="blue", cex=1.2)
    text(ans$x + .001, ans$y, lab = round(ans$z, 2), col="blue", cex=1)
    
    c(ans$ix[2], ans$iy[2])
    c(findInterval(df_examp$x[2], grid_examp$x),
      findInterval(df_examp$y[2], grid_examp$y))
    
    ## NOT RUN ##
    ## These should generate an error
    ans <- interpolate_xy(grid_examp, df_examp$x + 1, df_examp$y)
    ans <- interpolate_xy(grid_examp, df_examp$x - 1, df_examp$y)
    ans <- interpolate_xy(grid_examp, df_examp$x, df_examp$y + 1)
    ans <- interpolate_xy(grid_examp, df_examp$x, df_examp$y - 1)
    
}

